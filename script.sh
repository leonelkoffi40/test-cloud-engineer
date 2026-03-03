#!/bin/bash

# les variables à refinir

CRED=myregistry
url ='http://localhost:5000'
trustDigest='Accept: application/vnd.docker.distribution.manifest.v2+json'
repo='mylpine'
NbreImageAlaisse=10

def tags=[]
def apiUrl = "${url}/v2/${repo}/tags/list"
def response = sh(script: " curl -s -u ${CRED} ${apiUrl} ", returnStatus: true) 

if (response == 0) {
    def jsonData = sh(script: " curl -s -u ${CRED} ${apiUrl} | jq -r '.tags[]' ", returnStdout: true).trim()
    tags = jsonData.split('\n')
} else {
      echo "Erreur lors de la récupération des tags."
        }

        tags=tags.sort()
         echo "$tags"
             compteur=0

        for (def tag in tags){
            if(compteur< (tags.size()-$NbreImageAlaisse)){
            def digest=sh(script:""" curl -v --silent -H "${trustDigest}" -XGET -u $CRED $url/v2/malpine/manifests/$tag 2>&1 | grep Docker-Content-Digest | awk '{print (\$3)}' """, returnStdout: true).trim()
                 //sh """ curl -v --silent -H "${trustDigest}" -X DELETE -u $CRED "${url}/v2/${repo}/manifests/${digest}" """
             compteur++
                            
             }
         }