#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Inception of Things - Part 3 (K3d ve Argo CD) Setup${NC}"
echo "======================================================"

# Çalışma dizini oluşturma
mkdir -p /tmp/iot-p3
cd /tmp/iot-p3

echo -e "${GREEN}[1/8] Gerekli paketleri kuruyorum...${NC}"
# Gerekli paketleri kur
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common git jq unzip

# Docker kurulumu
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker kurulumu başlatılıyor...${NC}"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker kuruldu. Lütfen grupları güncellemek için aşağıdaki komutu çalıştırın ve oturumu yeniden başlatın:"
    echo "newgrp docker"
else
    echo "Docker zaten kurulu."
fi

# K3d kurulumu
if ! command -v k3d &> /dev/null; then
    echo -e "${GREEN}K3d kurulumu başlatılıyor...${NC}"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "K3d zaten kurulu."
fi

# kubectl kurulumu
if ! command -v kubectl &> /dev/null; then
    echo -e "${GREEN}kubectl kurulumu başlatılıyor...${NC}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl zaten kurulu."
fi

# Helm kurulumu
if ! command -v helm &> /dev/null; then
    echo -e "${GREEN}Helm kurulumu başlatılıyor...${NC}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm zaten kurulu."
fi

# Ngrok kurulumu
if ! command -v ngrok &> /dev/null; then
    echo -e "${GREEN}Ngrok kurulumu başlatılıyor...${NC}"
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip
    unzip ngrok-stable-linux-amd64.zip
    sudo mv ngrok /usr/local/bin/
    rm ngrok-stable-linux-amd64.zip
    echo "Ngrok kuruldu. Lütfen https://dashboard.ngrok.com üzerinden bir hesap oluşturup auth token almanız gerekecek."
    echo "Token aldıktan sonra: ngrok authtoken <YOUR_TOKEN>"
else
    echo "Ngrok zaten kurulu."
fi

# ArgoCD CLI kurulumu
if ! command -v argocd &> /dev/null; then
    echo -e "${GREEN}ArgoCD CLI kurulumu başlatılıyor...${NC}"
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    chmod +x argocd-linux-amd64
    sudo mv argocd-linux-amd64 /usr/local/bin/argocd
else
    echo "ArgoCD CLI zaten kurulu."
fi

echo -e "${GREEN}[2/8] K3d cluster oluşturuyorum...${NC}"
# Eski cluster'ı temizle (eğer varsa)
k3d cluster delete iot-cluster 2>/dev/null

# Yeni cluster oluştur
k3d cluster create iot-cluster -p "8888:8888@loadbalancer" -p "8081:80@loadbalancer" -p "8443:443@loadbalancer" --agents 2

# Cluster'ın hazır olduğunu kontrol et
echo "Cluster hazır olana kadar bekleniyor..."
until kubectl get nodes | grep -q "Ready"; do
    sleep 5
    echo -n "."
done
echo ""
kubectl get nodes

echo -e "${GREEN}[3/8] Namespace'leri oluşturuyorum...${NC}"
# Namespace'leri oluştur
kubectl create namespace argocd
kubectl create namespace dev

echo -e "${GREEN}[4/8] ArgoCD kuruyorum...${NC}"
# ArgoCD kur
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD'nin hazır olmasını bekle
echo "ArgoCD hazır olana kadar bekleniyor..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || true

# ArgoCD şifresini al
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${YELLOW}ArgoCD Admin Şifresi: ${GREEN}$ARGOCD_PASSWORD${NC}"
echo $ARGOCD_PASSWORD > argocd-password.txt

# ArgoCD API sunucusuna port forwarding
echo "ArgoCD UI için port forwarding başlatılıyor..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
ARGOCD_PID=$!
echo "ArgoCD PID: $ARGOCD_PID"

# Port forwarding'in başlaması için bekle
sleep 5

echo -e "${GREEN}[5/8] Git deposu hazırlıyorum...${NC}"
# GitHub için proje dizini ve dosyaları oluştur
mkdir -p p3-repo
cd p3-repo

cat > deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil-playground
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wil-playground
  template:
    metadata:
      labels:
        app: wil-playground
    spec:
      containers:
      - name: wil-playground
        image: wil42/playground:v1
        ports:
        - containerPort: 8888
---
apiVersion: v1
kind: Service
metadata:
  name: wil-playground-svc
  namespace: dev
spec:
  selector:
    app: wil-playground
  ports:
  - port: 8888
    targetPort: 8888
  type: LoadBalancer
EOF

cd ..

echo -e "${GREEN}[6/8] ArgoCD uygulamasını yapılandırıyorum...${NC}"
# ArgoCD uygulaması tanımla
cat > application.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-playground
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/KULLANICI_ADINIZ/REPO_ADINIZ.git
    targetRevision: HEAD
    path: ./
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "GitHub kullanıcı adınızı girin:"
read GITHUB_USER

echo "GitHub depo adınızı girin:"
read GITHUB_REPO

# GitHub URL'sini güncelle
sed -i "s/KULLANICI_ADINIZ/$GITHUB_USER/g" application.yaml
sed -i "s/REPO_ADINIZ/$GITHUB_REPO/g" application.yaml

echo -e "${YELLOW}ArgoCD uygulaması GitHub'daki https://github.com/$GITHUB_USER/$GITHUB_REPO reposunu izleyecek.${NC}"
echo -e "${YELLOW}Lütfen GitHub'da bu depoyu oluşturup p3-repo dizinindeki dosyaları push edin.${NC}"

# create-repo.sh güncellemesi
cat > create-repo.sh << 'EOF'
#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Çalışma dizinini belirle
REPO_DIR="/tmp/iot-p3/p3-repo"

# .env dosyasından token'ı oku
if [ -f .env ]; then
  source .env
  if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}GITHUB_TOKEN .env dosyasında tanımlı değil!${NC}"
    exit 1
  fi
else
  echo -e "${RED}.env dosyası bulunamadı!${NC}"
  echo -e "${YELLOW}Lütfen şu komutu çalıştırın:${NC}"
  echo 'echo "GITHUB_TOKEN=your_token" > .env'
  exit 1
fi

echo -e "${YELLOW}GitHub reposu oluşturuluyor...${NC}"

cd $REPO_DIR
git init
git config user.email "tkaragoz@etudiant.42.fr"
git config user.name "karagoz36"
git add .
git commit -m "İlk commit: v1 deploymentı"

# Eğer remote zaten varsa kaldır
git remote remove origin 2>/dev/null

# Token kullanarak yeni remote ekle
git remote add origin https://karagoz36:${GITHUB_TOKEN}@github.com/karagoz36/IoT_scripts.git

echo -e "${YELLOW}Dosyalar GitHub'a push ediliyor...${NC}"
git push -f -u origin master

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Repository başarıyla oluşturuldu ve dosyalar push edildi.${NC}"
  echo -e "${YELLOW}ArgoCD otomatik olarak repository'yi izlemeye başlayacak.${NC}"
else
  echo -e "${RED}Repository oluşturma veya push işlemi başarısız oldu.${NC}"
  echo "Lütfen GitHub repository'nizin varlığını ve token'ın geçerliliğini kontrol edin."
fi
EOF


chmod +x create-repo.sh
echo -e "${YELLOW}GitHub reponuzu oluşturmak için create-repo.sh scriptini çalıştırabilirsiniz.${NC}"

echo -e "${GREEN}[7/8] ArgoCD uygulamasını oluşturuyorum...${NC}"
# ArgoCD uygulamasını oluştur
kubectl apply -f application.yaml
echo "ArgoCD uygulaması oluşturuldu."

echo -e "${GREEN}[8/8] Güncelleme ve test scriptlerini hazırlıyorum...${NC}"
# Uygulama güncelleme scripti
cat > update-to-v2.sh << EOF
#!/bin/bash
cd p3-repo
sed -i 's/wil42\/playground\:v1/wil42\/playground\:v2/g' deployment.yaml
git add deployment.yaml
git commit -m "Update: v2 deployment"
git push origin master
echo "Deployment v2'ye güncellendi ve GitHub'a push edildi."
echo "ArgoCD otomatik olarak değişikliği algılayacak ve uygulamayı güncelleyecek."
EOF

chmod +x update-to-v2.sh

# Test scripti
cat > test-app.sh << 'EOF'
#!/bin/bash
echo "Uygulama için port forwarding başlatılıyor..."
kubectl port-forward svc/wil-playground-svc -n dev 8888:8888 > /dev/null 2>&1 &
PF_PID=$!
echo "Port forwarding PID: $PF_PID"

sleep 5

echo "Uygulamayı test ediyorum..."
RESPONSE=$(curl -s http://localhost:8888/)
echo "Uygulama yanıtı: $RESPONSE"

echo "Port forwarding'i sonlandırmak için: kill $PF_PID"
EOF

chmod +x test-app.sh

# Ngrok ile webhook tetikleme scripti
cat > start-ngrok.sh << 'EOF'
#!/bin/bash
# ArgoCD API için ngrok tüneli başlat
ngrok http 8080 > /dev/null &
echo "Ngrok başlatıldı."

# Ngrok URL'sini göster
sleep 5
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "GitHub Webhook URL'si: $NGROK_URL/api/webhook"
echo "Bu URL'yi GitHub repo > Settings > Webhooks > Add webhook bölümüne ekleyin."
echo "Content type: application/json olarak ayarlayın."
EOF

chmod +x start-ngrok.sh

# Özet bilgileri göster
echo ""
echo "======================================================"
echo -e "${YELLOW}IoT Part 3 - Kurulum tamamlandı!${NC}"
echo "======================================================"
echo -e "ArgoCD UI: ${GREEN}https://localhost:8080${NC}"
echo -e "Kullanıcı adı: ${GREEN}admin${NC}"
echo -e "Şifre: ${GREEN}$(cat argocd-password.txt)${NC}"
echo ""
echo -e "${YELLOW}Adımlar:${NC}"
echo "1. GitHub'da $GITHUB_USER/$GITHUB_REPO adında bir repo oluşturun."
echo "2. ./create-repo.sh ile dosyaları GitHub'a push edin."
echo "3. ./test-app.sh ile uygulamayı test edin (v1 göreceksiniz)."
echo "4. ./update-to-v2.sh ile v2'ye güncelleyin."
echo "5. ./test-app.sh ile güncellenen uygulamayı test edin (v2 göreceksiniz)."
echo ""
echo "ArgoCD UI'ya erişim için kullanılan port forwarding'in PID'si: $ARGOCD_PID"
echo "Sonlandırmak için: kill $ARGOCD_PID"
echo "======================================================"
