레드마인 4.2.3 도커 설치

git clone  https://github.com/choiss7/redmine

cd redmine

vi docker-compose.yml   (디렉토리 폴더 수정)

docker-compose up -d 

http://ui:port     id : admin  , pass :admin 



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
  
