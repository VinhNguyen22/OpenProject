# OpenProject

sudo mkdir -p /var/lib/openproject/{pgdata,assets} 

git clone https://github.com/VinhNguyen22/OpenProject.git
 
docker build -t openproject-with-slack .


docker run -d -p 4444:80   -e OPENPROJECT_HOST__NAME=project.palazzo.com.vn   -e OPENPROJECT_SECRET_KEY_BASE=Pass1234  -e OPENPROJECT_HTTPS=false -e OPENPROJECT_SMTP__OPENSSL__VERIFY__MODE=none   -v /var/lib/openproject/pgdata:/var/openproject/pgdata  -v /var/lib/openproject/assets:/var/openproject/assets   openproject-with-slack
