#
# Cookbook:: hls-sample
# Recipe:: nginx
#
# Copyright:: 2019, The Authors, All Rights Reserved.

group "nginx" do
  action :create
  system true
end

user "nginx" do
  comment 'nginx user'
  home '/var/cache/nginx'
  shell '/sbin/nologin'
  group 'nginx'
  system true
  action :create
end

execute "yum groupinstall devtools" do
  user 'root'
  command 'yum -y groupinstall "Development Tools"'
  action :run
end

%W(
  epel-release
  perl
  perl-devel
  perl-ExtUtils-Embed
  libxslt
  libxslt-devel
  libxml2
  libxml2-devel
  gd
  gd-devel
  GeoIP
  GeoIP-devel
).each do |pkg|
  package "#{pkg}" do
    action [:install]
  end
end

directory "/var/log/nginx" do
  owner 'nginx'
  group 'nginx'
  recursive true
  mode 0755
  action :create
  not_if { ::File.exist? "/var/log/nginx" }
end

directory "/var/cache/nginx/" do
  owner 'nginx'
  group 'nginx'
  recursive true
  mode 0755
  action :create
  not_if { ::File.exist? "/var/cache/nginx/" }
end

NGINX_WORKING_DIRECTORY = '/var/tmp/nginx_sources'

directory "#{NGINX_WORKING_DIRECTORY}" do
  owner 'root'
  group 'root'
  recursive true
  mode 0755
  action :create
  not_if { ::File.exist? "#{NGINX_WORKING_DIRECTORY}" }
end

bash "download PCRE" do
  user 'root'
  cwd "#{NGINX_WORKING_DIRECTORY}"
  code <<~EOC
    wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz
    tar xzvf pcre-8.40.tar.gz
    rm pcre-8.40.tar.gz
  EOC
  not_if { ::File.exist? "/usr/sbin/nginx" }
end

bash "download zlib" do
  user 'root'
  cwd "#{NGINX_WORKING_DIRECTORY}"
  code <<~EOC
    wget https://www.zlib.net/zlib-1.2.11.tar.gz
    tar xzvf zlib-1.2.11.tar.gz
    rm zlib-1.2.11.tar.gz
  EOC
  not_if { ::File.exist? "/usr/sbin/nginx" }
end

bash "download OpenSSL" do
  user 'root'
  cwd "#{NGINX_WORKING_DIRECTORY}"
  code <<~EOC
    wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz
    tar xzvf openssl-1.1.0f.tar.gz
    rm openssl-1.1.0f.tar.gz
  EOC
  not_if { ::File.exist? "/usr/sbin/nginx" }
end

bash "download nginx-rtmp-module" do
  user 'root'
  cwd "#{NGINX_WORKING_DIRECTORY}"
  code <<~EOC
    wget https://github.com/arut/nginx-rtmp-module/archive/master.zip
    unzip master.zip
    rm master.zip
  EOC
  not_if { ::File.exist? "/usr/sbin/nginx" }
end

NGINX_SOURCE = 'nginx-1.13.2'

bash "install Nginx" do
  user 'root'
  cwd "#{NGINX_WORKING_DIRECTORY}"
  code <<~EOC
    wget https://nginx.org/download/#{NGINX_SOURCE}.tar.gz
    tar zxvf #{NGINX_SOURCE}.tar.gz
    rm #{NGINX_SOURCE}.tar.gz
    cd #{NGINX_SOURCE}
    ./configure \
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib64/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --user=nginx \
      --group=nginx \
      --build=CentOS \
      --builddir=nginx-1.13.2 \
      --with-select_module \
      --with-poll_module \
      --with-threads \
      --with-file-aio \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_xslt_module=dynamic \
      --with-http_image_filter_module=dynamic \
      --with-http_geoip_module=dynamic \
      --with-http_sub_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_auth_request_module \
      --with-http_random_index_module \
      --with-http_secure_link_module \
      --with-http_degradation_module \
      --with-http_slice_module \
      --with-http_stub_status_module \
      --http-log-path=/var/log/nginx/access.log \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --with-mail=dynamic \
      --with-mail_ssl_module \
      --with-stream=dynamic \
      --with-stream_ssl_module \
      --with-stream_realip_module \
      --with-stream_geoip_module=dynamic \
      --with-stream_ssl_preread_module \
      --with-compat \
      --with-pcre=../pcre-8.40 \
      --with-pcre-jit \
      --with-zlib=../zlib-1.2.11 \
      --with-openssl=../openssl-1.1.0f \
      --with-openssl-opt=no-nextprotoneg \
      --with-http_ssl_module \
      --add-module=../nginx-rtmp-module-master \
      --with-debug
    make
    make install
    chown -R nginx:nginx /etc/nginx
    ln -s /usr/lib64/nginx/modules /etc/nginx/modules
  EOC
  not_if { ::File.exist? "/usr/sbin/nginx" }
end

%W(
  conf.d
  sites-enabled
).each do |dir|
  directory "/etc/nginx/#{dir}" do
    owner 'nginx'
    group 'nginx'
    recursive true
    mode 0755
    action :create
    not_if { ::File.exist? "/etc/nginx/#{dir}" }
  end
end

directory "/var/www/vhosts" do
  owner 'nginx'
  group 'nginx'
  recursive true
  mode 0755
  action :create
  not_if { ::File.exist? "/var/www/vhosts" }
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner 'nginx'
  group 'nginx'
  mode 0644
  notifies :run, 'execute[restart Nginx service]'
end

cookbook_file "/usr/lib/systemd/system/nginx.service" do
  source 'nginx.service'
  owner 'nginx'
  group 'nginx'
  mode 0644
end

execute "restart Nginx service" do
  user 'root'
  command 'systemctl restart nginx.service'
  action :nothing
end

execute "enable Nginx service" do
  user 'root'
  command 'systemctl enable nginx.service'
  action :run
end

execute 'enable http access' do
  user 'root'
  command 'firewall-cmd --add-service=http --zone=public --permanent'
  notifies :run, 'execute[reload firewalld]'
end
