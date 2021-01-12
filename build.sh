#!/usr/bin/env bash

# ATTENTION!! Make sure you have altered your terraform.tfvars for your environment.
# ATTENTION!! Make sure you have already have you AWS credentials configured.

export CLUSTER="cluster"
export APP_NAME="service"
export AWS_ACC_ID="094579366022"
export REGION=$(find . -iname "terraform.tfvars" | xargs -I {} cat {} | grep -e region | cut -d \= -f2 | sed 's/ "//g;s/"//g')

f_get_lb_dns () {
    export LB_DNS=$(cat terraform.tfstate.d/prod/terraform.tfstate | grep -P4 outputs | grep value | cut -d : -f2 | sed 's/ //g;s/\"//g')
}

f_get_service_properties() {
    SERVICE_PROPERTIES="$(aws ecs describe-services --cluster ${CLUSTER} --region ${REGION} --services ${APP_NAME} --output json)"
}

f_get_service_desired() {
    PRIMARY_DESIRED_COUNT=$(echo $SERVICE_PROPERTIES | jq --raw-output '.services[].deployments[] | select(.status == "PRIMARY") | .desiredCount')
}

f_get_service_running() {
    PRIMARY_RUNNING_COUNT=$(echo $SERVICE_PROPERTIES | jq --raw-output '.services[].deployments[] | select(.status == "PRIMARY") | .runningCount')
}

f_execute_migrations() {
    # matéria 1
    curl -sv ${LB_DNS}:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"first post!","content_id":1}'
    curl -sv ${LB_DNS}:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"ok, now I am gonna say something more useful","content_id":1}'
    curl -sv ${LB_DNS}:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I agree","content_id":1}'

    # matéria 2
    curl -sv ${LB_DNS}:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I guess this is a good thing","content_id":2}'
    curl -sv ${LB_DNS}:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"charlie@example.com","comment":"Indeed, dear Bob, I believe so as well","content_id":2}'
    curl -sv ${LB_DNS}:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"eve@example.com","comment":"Nah, you both are wrong","content_id":2}'
}

f_check_deployment() {
    f_get_service_properties
    f_get_service_desired
    f_get_service_running

	echo -e "Waiting 5 minutes before deployment FAILS...\n"
	echo "The service desiredCount is: ${PRIMARY_DESIRED_COUNT}"
	echo -e "The service current runningCount is: ${PRIMARY_RUNNING_COUNT}\n"
	while [ "${PRIMARY_RUNNING_COUNT}" != "${PRIMARY_DESIRED_COUNT}" ]; do
		sleep 2
		counter=$((counter+1))
		echo "Waiting until the service gets updated with new tasks..."
		f_get_service_properties
		f_get_service_running
		if [ "${PRIMARY_RUNNING_COUNT}" == "${PRIMARY_DESIRED_COUNT}" ]; then
			PRIMARY_RUNNING_COUNT="0"
			runningCounter=$((runningCounter+1))
			echo "System acquired ${runningCounter} of 3 datapoints to declare deployment done."
		fi
		if [[ "${runningCounter}" == "3" ]]; then
			break
		fi
		if [[ "${counter}" == "120" ]]; then
			echo "Exiting after 300 seconds. Deploy was NOT completed successfully!"
            exit 1
        fi
	done
	echo -e "The service has been deployed successfully!\n"
	f_get_service_properties
    f_get_service_running
	echo "The service desiredCount is: ${PRIMARY_DESIRED_COUNT}"
	echo "The service current runningCount is: ${PRIMARY_RUNNING_COUNT}"
}

f_install_terraform() {
    if [ ! -f $(which terraform) ]; then
        wget https://releases.hashicorp.com/terraform/0.12.05/terraform_0.12.05_linux_amd64.zip
        unzip terraform_0.12.05_linux_amd64.zip
        mv terraform /usr/local/bin/terraform
        rm terraform_0.12.05_linux_amd64.zip
    else
        echo "You already have terraform installed."
    fi
}

f_deploy_infra() {
    cd terraform
    terraform init
    terraform workspace select prod
    echo "Workspace $(terraform workspace show) selected"
    terraform apply --auto-approve
}

f_wait_healthcheck() {
    sleep 20
}

f_destroy_infra() {
    echo "This will DESTROY your whole environment, do you want to CONTINUE?(y|N)"
    read CONTINUE

    if [[ ${CONTINUE} == "y" ]] || [[ ${CONTINUE} == "yes" ]] || [[ ${CONTINUE} == "Y" ]] || [[ ${CONTINUE} == "YES" ]]; then
        cd terraform && terraform destroy --auto-approve
    elif [[ ${CONTINUE} == "" ]] || [[ ${CONTINUE} == "n" ]] || [[ ${CONTINUE} == "no" ]] || [[ ${CONTINUE} == "N" ]] || [[ ${CONTINUE} == "NO" ]]; then
        echo "Exiting now..."
        exit 1
    fi
}

f_pipeline_deployment() {
    docker build -f Dockerfile -t "${AWS_ACC_ID}".dkr.ecr."${REGION}".amazonaws.com/service:latest .
    $(aws ecr get-login --no-include-email --region ${REGION})
    docker push "${AWS_ACC_ID}".dkr.ecr."${REGION}".amazonaws.com/service:latest
    aws ecs update-service --cluster cluster --region "${REGION}" --service service --force-new-deployment
}

while [ ! -z "$1" ]; do
    case "$1" in
        deploy)
            f_install_terraform
            f_deploy_infra
            f_check_deployment
            f_wait_healthcheck
            f_get_lb_dns
            f_execute_migrations
        ;;

        destroy)
            f_destroy_infra
        ;;

        pipeline)
            f_pipeline_deployment
        ;;

        *)
            echo "You must pass one of the parameter: deploy | destroy | pipeline"
            exit 1
        ;;
    esac
shift
done