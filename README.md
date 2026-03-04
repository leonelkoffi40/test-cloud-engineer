                                TEST TECHNIQUE CLOUD ENGINEER

        ***** JOUR1 *****

A. Conception de l'architecture

Dans le cadre de ce projet, la conception repose sur la mise en place d’une architecture cloud distribuée, dynamique et sécurisée. L’architecture proposée s’appuie sur un serveur dédie ou qui nous permettra de créer des machines virtuelles. 
Notre  Architecture est composée d’un serveur sur lequel tourne:
- Un pare-feu shorewall qui va des zones et des règles pour protéger les VMs à  l’exposition sur internet qui est très dangereuse. 
- Un vpn wireguard pour protéger la connection ssh aux VMs
- Un reverse proxy nginx  pour l’ensemble de l’infrastructure
-  Trois VMs de déploiements (trois environnements): dev, staging et prod
- Une VM  pour le système de surveillance(monitoring): le système de surveillance est composé de la surveillance des métrics des machines et des applications en utilisant prometheus et grafana  et la surveillance des journaux en utilisant Loki et promtail.
- Une VM pour le serveur de la base de donnée Postgres. 

Bien que l'architecture décrire au point dessus semble nous convient de pour demarrer (Tout comme les technologies avancent très vite, les infrastructures sont vivantes et donc à évoluer) mais on est contraint par les resources(le serveur est une VM et ne supporte pas la virtualisation donc on est contraint de travailler sur une seule VM). 

NB: Image d'architecture est à la racine du projet et est nommé Achitecture-cloud-souhaitée.png


B. Réalisation
  B1. renforcer la sécurité du serveru

La sécurité est avant tout le grand défi sur l'internet et il nous est important de poser quelques pillier de la sécurité avant de commencer à travailler.

    1. Configuration du server ssh
Bien que ssh établit une connection sécurisée, une mavaise configuration expose votre serveur à l'insécurité. Pour ce là nous allons légèrement modifier la configuration ssh. On cré un fichier un fichier conf dans le répertoir /etc/ssh/sshd_config.d/

`vim /etc/ssh/sshd_config.d/custom.conf`

et on edit comme suit 

```
Port 8200
AllowUsers user1
PermitRootLogin no
MaxAuthTries 4
PermitEmptyPasswords no
```

1- on change le port ssh
2- on authorise les utilisateur à se connecter 
3- eviter la connexion ssh sur root  ##important
4- Nombre de tentantive connexion echoué au serveur
5- eviter la connexion sans mot de passe

    2. fail2ban 
Afin que le point 4 ci-dessus  contribut à renforce notre sécuriser, il faut bloquer ou banir l'utilisateur après ces 4 tentantives.

    3. rkhunter 
rkhunter viendra nous signaler les rookit, les portes derobées, les mauvaise configuration 

NB: voici constitue notre base pour la protection du serveur.

B2. Suite de la journée:
Defaut avancer sur le cluster k8 et terraform dû à l'accès au Vms. j'ai configuré Docker et le serveur de la base de donnée postgrés. 
   1. Installation Docker 
docker a été installé sur suivant leur documentation disponible sur le lien suivant:
https://docs.docker.com/engine/install/ubuntu/. Docker tourne en root est qui est un mininum de sécurité. Mais on peut en renforcer la sécurité en configurant docker d'utiliser l'api docker en tls et non le socket docker.

 2. Installation Postgres
 Postgres est installé en utilisant un fichier docker compose pour sa souplesse et la simplicité à diagnosquer en quand de problème. 
 La base de donne est un élément critique dans une infrastructure et pour cela il faut le sécurisé.
    * Ce que j'ai fait 
Pour commencer j'ai créé un réseau docker dédie à la base de donnée. Ce réseau ne sera accessible que pour les conteneurs qui néccessite une connexion à la base de donnée et postgres ne écoute les connexions que sur cette interface. J'ai ensuite authorisé les connexions des hôtes qui ne sont que dans cet réseau et donc pas accessible directement sur internet.
    * Ce que je pense fait ensuite
Vue que tout l'infra est sur la même machine j'ai pas configuré la connexion TLS sur la base de donnée, ce qu'il faudra fait ensuite.

NB: Toujours en mettant la sécurité en avant, avant de choisir la version à installer, j'ai documenté sur ça et j'ai verifié dans au moins deux bases de données des vunérabilités connues. Et ça été la même pour toutes les versions choisies.


 ***** JOUR2 *****

 A. système de monitoring 
 j'ai configuré le système de monitoring des metrics composé de prometheus, grafana, alertnamanger, node-exporter et cadvisor. j'ai eu également à configurer des alerts pour: les nodes(un seul node dans notre cas), les container et prometheus lui même.

NB: Pour la réception de notification d'alertmanager j'ai utilisé un wehbook à defaut de mail ou de serveur de messagerie.
lien du webhook: https://webhook.site/#!/view/c0f4bf17-5a1a-486b-86af-2ade9166f704/da5843d4-ee9b-4e4c-8f9e-294d0f3de986/1 

B. Pipeline cicd
Il est composé gitlab ci et ansible pour le deploiément. Bien que j'ai fini de configurer l'ansible pour le deploiement, je n'ai pas pu terminer avec le gitlab-ci pour l'integration .

Question au choix
    * suppresion des images docker

J'ai eu à travailler sur un sujet pareil qui consiste à supprimer les images dans un registre e laissant à un nombre les plus récents; par exemple supprimer les images en laissant les 10 images les récents d'un dépot. Ce travail a été fait avec un script bash mais depuis jenkins pour pouvoir mettre l'approbation de suppression. 
Et donc j'ai pris ce travail déjà fait que j'éssaie de l'adapter en script purement bash mais je n'ai pas non plus fini et tester.





NB: tous les fichiers serons à coté de ce readme.md