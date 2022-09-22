#!/bin/bash
wget https://github.com/vmware-tanzu/velero/releases/download/v1.9.1/velero-v1.9.1-linux-amd64.tar.gz

tar -xf velero-v1.9.1-linux-amd64.tar.gz
sleep 3
cd velero-v1.9.1-linux-amd64
sudo cp velero /usr/local/bin
cd ..
rm -r velero-v1.9.1-linux-amd64

BUCKET=$1
gsutil mb gs://$BUCKET/

GSA_NAME=$2
gcloud iam service-accounts create $GSA_NAME --display-name "Velero service account"

if [[ $(gcloud iam service-accounts list | grep Velero service account) ]];then
    echo "Service account oluşturulmuş işleme devam ediliyor.."

    SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --filter="displayName:Velero service account" --format 'value(email)')

    ROLE_PERMISSIONS=(
    compute.disks.get
    compute.disks.create
    compute.disks.createSnapshot
    compute.snapshots.get
    compute.snapshots.create
    compute.snapshots.useReadOnly
    compute.snapshots.delete
    compute.zones.get
    storage.objects.create
    storage.objects.delete
    storage.objects.get
    storage.objects.list
    )

    if [[ $(gcloud iam roles list --project=$PROJECT_ID | grep "Velero Server") ]];
    then
        echo "Rol daha önce oluşturulmuş."
    else
        gcloud iam roles create velero.server \
        --project $PROJECT_ID \
        --title "Velero Server" \
        --permissions "$(IFS=","; echo "${ROLE_PERMISSIONS[*]}")"

    gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role projects/$PROJECT_ID/roles/velero.server

    gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://${BUCKET}

    NAMESPACE=$4
    kubectl create namespace $NAMESPACE

    KSA_NAME=$3
    kubectl create serviceaccount $KSA_NAME --namespace $NAMESPACE

    gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:[$PROJECT_ID].svc.id.goog[$NAMESPACE/$KSA_NAME]" \
    [$GSA_NAME]@[$PROJECT_ID].iam.gserviceaccount.com

    velero install \
    --provider gcp \
    --plugins velero/velero-plugin-for-gcp:v1.5.0 \
    --bucket $BUCKET \
    --no-secret \
    --sa-annotations iam.gke.io/gcp-service-account=[$GSA_NAME]@[$PROJECT_ID].iam.gserviceaccount.com \
    --backup-location-config serviceAccount=[$GSA_NAME]@[$PROJECT_ID].iam.gserviceaccount.com \
else
    echo "Service account bulunamadı işlem iptal edildi."
fi
