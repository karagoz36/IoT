#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Inception of Things - Part 3: Uygulama Testi${NC}"
echo "======================================================"

# Uygulama pod'unun çalışıp çalışmadığını kontrol et
echo -e "${GREEN}Uygulama pod'ları kontrol ediliyor...${NC}"
POD_STATUS=$(kubectl get pods -n dev -l app=wil-playground -o jsonpath='{.items[0].status.phase}' 2>/dev/null)

if [ -z "$POD_STATUS" ]; then
    echo -e "${RED}Uygulama pod'u bulunamadı. ArgoCD uygulamasının senkronize olduğundan emin olun.${NC}"
    echo "ArgoCD UI'da uygulamanın durumunu kontrol edin: https://localhost:8080"
    exit 1
fi

if [ "$POD_STATUS" != "Running" ]; then
    echo -e "${RED}Uygulama pod'u çalışmıyor. Durum: $POD_STATUS${NC}"
    echo "Pod detaylarını kontrol edin: kubectl describe pod -n dev -l app=wil-playground"
    exit 1
fi

echo -e "${GREEN}Uygulama pod'u çalışıyor. Durum: $POD_STATUS${NC}"

# Mevcut bir port forwarding varsa sonlandır
PF_PID=$(ps -ef | grep "kubectl port-forward svc/wil-playground-svc" | grep -v grep | awk '{print $2}')
if [ ! -z "$PF_PID" ]; then
    echo -e "${YELLOW}Mevcut port forwarding sonlandırılıyor (PID: $PF_PID)...${NC}"
    kill $PF_PID 2>/dev/null
    sleep 2
fi

# Uygulama için port forwarding başlat
echo -e "${GREEN}Uygulama için port forwarding başlatılıyor...${NC}"
kubectl port-forward svc/wil-playground-svc -n dev 8888:8888 > /dev/null 2>&1 &
PF_PID=$!
echo "Port forwarding PID: $PF_PID"

# Port forwarding'in başlaması için bekle
sleep 3

# Uygulamayı test et
echo -e "${GREEN}Uygulamayı test ediyorum...${NC}"
RESPONSE=$(curl -s http://localhost:8888/ 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}Uygulama yanıt vermiyor. Port forwarding'i kontrol edin.${NC}"
    echo "kubectl logs -n dev -l app=wil-playground komutu ile uygulama loglarını kontrol edin."
else
    echo -e "${GREEN}Uygulama yanıtı:${NC} $RESPONSE"
    
    # Yanıtı analiz et
    if [[ $RESPONSE == *"v1"* ]]; then
        echo -e "${YELLOW}Uygulama şu anda v1 sürümünü çalıştırıyor.${NC}"
    elif [[ $RESPONSE == *"v2"* ]]; then
        echo -e "${YELLOW}Uygulama şu anda v2 sürümünü çalıştırıyor.${NC}"
    else
        echo -e "${YELLOW}Uygulama beklenmeyen bir yanıt döndürdü.${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}Not: Port forwarding aktif durumda (PID: $PF_PID).${NC}"
echo -e "${YELLOW}Sonlandırmak için: kill $PF_PID${NC}"
echo "======================================================"
