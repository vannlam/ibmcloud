ssh -p 32022 ubuntu@192.168.1.9 "/vol00/docker/si3-html/html/tournoi-interne.sh"
scp -P 32022 ubuntu@192.168.1.9:/tmp/tournoi-interne.tar .
scp tournoi-interne.tar u69555511@home421919569.1and1-data.host:/tournoi-interne
ssh u69555511@home421919569.1and1-data.host "cd tournoi-interne; tar -xvf tournoi-interne.tar"
