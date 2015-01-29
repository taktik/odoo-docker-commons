# OpenSSH-Server

Install and configure OpenSSH-Server.  
To be able to login to a container containing this server, add a public key in the templates
directory with the name id_rsa_docker.pub.  
This key will be copied into the authorized_keys.  

You will then be able to ssh into a container with:

    ssh -i id_rsa_docker root@ip_of_container
    
