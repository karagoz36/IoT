#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Inception of Things - Part 3: Uygulama v2'ye Güncelleniyor${NC}"
echo "======================================================"

cd /tmp/iot-p3/p3-repo || {
    echo "Repo dizini bulunamadı. Önce setup.sh scriptini çalıştırın."
    exit 1
}

echo -e "${GREEN}Deployment dosyası v1'den v2'ye güncelleniyor...${NC}"
sed -i 's/wil42\/playground\:v1/wil42\/playground\:v2/g' deployment.yaml

echo -e "${GREEN}Değişiklikler git'e commit ediliyor...${NC}"
git add deployment.yaml
git commit -m "Update: v2 deployment"

echo -e "${GREEN}Değişiklikler GitHub'a push ediliyor...${NC}"
git push origin master

echo -e "${YELLOW}Deployment v2'ye güncellendi ve GitHub'a push edildi.${NC}"
echo -e "${YELLOW}ArgoCD otomatik olarak değişikliği algılayacak ve uygulamayı güncelleyecek.${NC}"
echo -e "${YELLOW}Güncellenmiş uygulamayı test etmek için test-app.sh scriptini çalıştırın.${NC}"
