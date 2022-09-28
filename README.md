# bash-scripts
<h2> velero-wi.sh </h2>
<h3>Gereksinimler:</h3>
<ul>
<li>Google Cloud üzerinde Workload Identity uyumlu bir cluster.</li>
</ul>
<h3>İşlev:</h3>
<ul>
<li>Google Cloud üzerinde çalışabilmesi için gerekli Velero binary dosyalarını yükler.</li>
<li>Google Cloud üzerinde verildiği isimde Bucket oluşturur ve uygulamanın bu Bucket üzerine bağlanmasını sağlar.</li>
<li>Çalışabilmesi için gereken Google Service Account ve Kubernetes Service Account hesaplarını oluşturur.</li>
<li>Gerekli rol ve rol atamalarını yapar.</li>
<li>Oluşturulmuş konfigürasyonu ile Cluster üzerine Velero Deployment işlemini gerçekleştirir.</li>
</ul>
<h3>Kullanımı:</h3>

```

./velero-wi.sh [GCP Bucket ismi] [GCP Bucket Lokasyonu]

```
