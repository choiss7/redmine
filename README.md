<pre>

레드마인 4.2.3 도커 설치

git clone  https://github.com/choiss7/redmine

cd redmine
chmod -R ug+rw  * 
vi docker-compose.yml   (디렉토리 , 레드마인 IP 수정)
docker-compose up -d    
docker-compose logs -f 
  
설치된 레드마인 접속  (3분정도 대기)
http://ip:port     id : admin  , pass :admin 


프로젝트 개요 이미지 붙여넣기 오류 처리
ALTER TABLE projects MODIFY description MEDIUMTEXT;  
  

Environment:
  Redmine version                4.2.3.stable
  Ruby version                   2.6.9-p207 (2021-11-24) [x86_64-linux]
  Rails version                  5.2.6
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
SCM:
  Git                            2.35.1
  Filesystem                     
Redmine plugins:
  clipboard_image_paste          1.13
  redmine_ckeditor               1.2.3
  redmine_cms                    1.2.1
  redmine_lightbox2              0.5.1
  redmine_slack                  0.2  
</pre>
