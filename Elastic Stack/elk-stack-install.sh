# ----------------- Prerequisites ----------------

# To complete this tutorial, you will need the following:
# 1. An Ubuntu 22.04 server with 4GB RAM and 2 CPUs set up with a non-root sudo user.
# 2. OpenJDK 11 installed. See the section Installing the Default JRE/JDK
sudo apt install openjdk-11-jre-headless
# 3. Nginx installed on your server, which we will configure later in this guide as a reverse-proxy for Kibana. 
# - 3.1. Installing Nginx
    sudo apt update
    sudo apt install nginx -y
# - 3.2. Adjusting Firewall
    sudo ufw app list
# - 3.3. It is recommended that you enable the most restrictive profile that will still allow the traffic you’ve configured. Right now, we will only need to allow traffic on port 80.
    sudo ufw allow 'Nginx HTTP'
    sudo ufw status
# - 3.4. Checking your Web Server
    systemctl status nginx # Should be Active Running
# - 3.5. Fetch your server's ip 
    curl -4 icanhazip.com
# - 3.6. When you have your server’s IP address, enter it into your browser’s address bar
    # http://your_server_ip
# - 3.7. Start, Stop, Restart, Reload, Disable, Enable  Commands (Just in case you need them :)
    sudo systemctl stop nginx
    sudo systemctl start nginx
    sudo systemctl restart nginx
    sudo systemctl reload nginx
    sudo systemctl disable nginx
    sudo systemctl enable nginx

# 4. Remember to add security groups such as opening HTTP access on port 80

# ----------------- ElasticSearch ----------------
# Installing and configuring ElasticSearch

# Get the pacakages
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch |sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
# Get the gpg keys signed
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee - a /etc/apt/sources.list.d/elastic-7.x.list

# Install elastic-search
sudo apt update
sudo apt install elasticsearch

# Edit ElasticSearch config file
sudo nano /etc/elasticsearch/elasticsearch.yml
# To restrict access and therefore increase security, find the line that specifies network.host, 
# uncomment it, and replace its value with localhost

# Start the services 
sudo systemctl start elasticsearch
# Enable services
sudo systemctl enable elasticsearch

# You can test whether your Elasticsearch service is running by sending an HTTP request:
curl -X GET "localhost:9200"

# -------------------- Kibana ----------------------
#  Installing and Configuring the Kibana Dashboard

# Install Kibana
sudo apt install kibana

# Start & Enable the services 
sudo systemctl enable kibana
sudo systemctl start kibana

# The following command will create the administrative Kibana user and password, and store them
# in the htpasswd.users file. 
echo "kibanaadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users
# Create Nginx server block file
sudo nano /etc/nginx/sites-available/yuvi_domain # in file update your_domain to match your server’s FQDN or public IP address.
# Enable new configuration
sudo ln -s /etc/nginx/sites-available/yuvi_domain /etc/nginx/sites-enabled/yuvi_domain
# Check for syntax errors
sudo nginx -t
# Once you see syntax is ok in the output, go ahead and restart the Nginx service
sudo systemctl reload nginx
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'

# Kibana is now accessible via the public IP address of your Elastic Stack server.
# Check status by - http://your_domain/status
# Example - http://10.196.36.199/status


# -------------------------- Logstash ----------------------------------
# Installing & Configuring logstash

# Install Logstash
sudo apt install logstash

# Create a configuration file including the inputs and output parameters
sudo nano /etc/logstash/conf.d/first-pipeline.conf

# Test Logstash configuration with this command:
# Expected Output --> Config Validation Result: OK. 
# Along with some warnings regarding java version
sudo -u logstash /usr/share/logstash/bin/logstash --path.settings/etc/logstash -t

# Start and enable the logstash
sudo systemctl start logstash
sudo systemctl enable logstash


# -------------------------- Filebeat -----------------------------------------
# Installing and Configuring Filebeat

# Install filebeat
sudo apt install filebeat

# Edit configuration to use logstash as output
sudo nano /etc/filebeat/filebeat.yml

# In this tutorial we will use the system module, which collects and parses logs created by the system logging service of
# common Linux distributions.
sudo filebeat modules enable system
sudo filebeat modules list

# To load the ingest pipeline for the system module, enter the following command:
sudo filebeat setup --pipelines --modules system

# Load the template
sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'

# load dashboards when Logstash is enabled, you need to disable the Logstash output and enable
# Elasticsearch output:
sudo filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601

# Start and enable the filebeat
sudo systemctl start filebeat
sudo systemctl enable filebeat

# To verify that Elasticsearch is indeed receiving this data, query the Filebeat index with this command:
curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'

# If your output shows 0 total hits, Elasticsearch is not loading any logs under the index you
# searched for