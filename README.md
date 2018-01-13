#######################################################

ansible. Домашнее задание #10.

Основное ДЗ.
В корневом каталоге репозитория был создан каталог ansible/ и последующие операции исполнялись находясь в данном рабочем каталоге. 
Ansible версии 2.4 уже был установлен на машине:

ansible 2.4.2.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/azhelezov/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.12 (default, Nov 19 2016, 06:48:10) [GCC 5.4.0 20160609]

На GCP развернута stage инфраструктура из ДЗ №9. В результате были созданы два сервера приложения и БД.
Был создан вайл ./inventory в который были добавлены два созданных сервера и параметры подключения к ним. После чего проверено подключение к этим серверам посредством запуска на них модуля "ping" при помощи Ansible. 
Был создан файл конфигурации ./ansible.cfg в котором были указаны параметры запуска ansible по-умолчанию. После чего из файла ./inventory была убрана вся не необходимая информация и оставлены только переменные определяющие для хостов их внешние ip-адреса для подключения к ним. Сам файл ./iventory так же указан в конфиге и теперь при запуске ansible не нужно указывать на него параметром "-i". Работу ansible проверил при помощи запуска модуля "command" с атрибутом "uptime" на обоих серверах.
Далее файл ./inventory был изменен: каждый хост был добавлен в группу: app или db. Запуск ansible осуществлялся теперь с указанием не имен хостов, а групп: app, db, а так же специальной группы all которая включает в себя все хосты файла-инвентаря.


#######################################################

terraform. Домашнее задание #8.

Основное ДЗ.
На рабочем компьютере был установлен инструмент Terraform (Hashicorp).
В данном репозитории создан каталог ./terraform, в котором заведен основной конфигурационный файл terraform-а: main.tf. В main.tf описана инфраструкура проекта.
Так же создан файл конфигурации для описания выходных переменных: outputs.tf. В нем описана выходная переменная "app_external_ip", которая хранит во время работы terraform значение внешнего ip-адреса создаваемой ВМ.
Далее в main.tf был добавлен ресурс для определения правила фаервола "firewall_puma" для доступа к приложению из Интернет. Правило откывает доступ по порту tcp/9292 к инстансам с тегом "reddit-app".
Тег "reddit-app" так же добавлен в описание ресурса создания инстанса.
Далее в main.tf добавлены два провиженера: для копирования файла-юнита на созданный инстанс и скрипта применяющего данный юнит для автозапуска приложения и веб-сервера. Юнит и скрипт лежат в каталоге terraform/files проекта.
Создан файл variables.tf в котром прописано задание input-переменных для параметризирования некоторых значений в файле main.tf.
Значения переменных определены в файле terraform.tfvars. Образец этого файла размещен в репозитории: terraform.tfvars.example. По образцу данного файла нужно задать ваши значения переменных, и переименовать файл в terraform.tfvars перед запуском terraform-а. Задать нужно:
- ваш ID проекта;
- пути по которым лежат секретный и открытый ключи пользователя "appuser" (пользователь с таким именем будет создан в инстанасе и от его имени будет производиться подключение провиженеров к ВМ);
- семейство образов или образ из которого будет создан загрузочный диск (данный образ\семейство должен существовать);
-  регион и зону для создания инстанса.

Задание со звездочкой 1. *


#######################################################

packer-base. Домашнее задание #7.

Основное ДЗ.
Создан backed-образ из из базового образа семейства ubuntu-1604-lts. 
Для создания нужно использовать утилиту Packer (Hashicorp) и шаблон ubuntu16.json, а так же можно использовать файл переменных. Пример такого файла это файл variables.json.example. 
Переменные которые необходимо определить при использовании данного шаблона: 
proj_id - (PROJect_ID), ID вашего проекта на Google Cloud; 
s_im_fam - (Source_IMage_FAMily), "семейство" образов исходного образа, использовать нужно именно "ubuntu-1604-lts", хотя это можно и переопределить, но тогда все сопутствующие возможные нюансы нужно учитывать.

Можно переопределить и другие переменные. Запуск packer с использованием файла переменных производится командой:

~$: packer build -var-file=./variables.json ./ubuntu16.json

, или переменные можно задать непосредственно из коммандной строки, если запускать packer командой:

~$: packer validate -var 'proj_id=infra-XXXXX' -var 's_im_fam=ubuntu-1604-lts' ubuntu16.json

Запуск создания образа нужно производить из каталога packer/ репозитория.
В результате в GCP будет создан образ reddit-base-{{timestamp}} из семейства образов reddit-base.


Задание со звездочкой 1.
На основе ubuntu16.json создан immutable-шаблон с встроенными ruby, mongodb и дополнительно автозапуском веб-сервера "puma". 
Для создания образа нужно использовать утилиту Packer (Hashicorp) и шаблон immutable.json, а так же можно использовать файл переменных как описано выше, либо задать переменные в строке запуска.
Переменные которые необходимо определить при использовании данного шаблона те же что и для шаблона ubuntu16.json:
proj_id - (PROJect_ID), ID вашего проекта на Google Cloud;
s_im_fam - (Source_IMage_FAMily), "семейство" образов исходного образа, использовать нужно именно "ubuntu-1604-lts", хотя это можно и переопределить, но тогда все сопутствующие возможные нюансы нужно учитывать.
В результате создается образ в котором уже настроен автозапуск приложения. Для создания этого образа в директории files/ есть файл-юнит для systemd-сервиса puma-сервера (packer/files/puma.service), а так же дополнительный скрипт для настройки и запуска этого сервиса: scripts/serv_deploy.sh


Задание co звездочкой 2.
Cоздан bash-скрипт для автоматического развертывания инстанса из образа семейства reddit-full, созданного из шаблона immutable.json.
Скрипт ./config-scripts/create-reddit-vm.sh можно запускать откуда угодно. Внутри скрипта для удобства определения вначале выведены переменные и одна из них позволяет задать свой ID проекта: GCP_PROJECT_ID.
В скрипте есть добавление тега сети ("puma-server"), открывающего для созданной ВМ (инстанса) порт 9292 в правилах фаервола. Т.о. после развертывания инстанса можно сразу зайти на его ip-адрес по порту http/9292.

#######################################################

Infra-2. Домашнее задание #6.

#gcloud command to make an instance

gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --zone=europe-west1-b \
  --metadata startup-script='wget -O - https://gist.githubusercontent.com/AndreyZhelezov/6ba77a556587adecf1702afd0ddd7d17/raw/b5df4246d74c3cbbdfe373989c090e4273a54f7c/startup_script.sh | bash'

#######################################################

Infra-1. Домашнее задание #5.

1 Задание: нужно подключиться к инстансу который находится в частной сети (inter-host-1) сквозь инстанс с белым ip (bastion), используя команду в одну строку.

Исходные данные созданных инстансов виртуальных машин:
Host bastion private-ip:	10.132.0.2	public-ip: 35.205.217.70
Host inter-host-1 private-ip:	10.132.0.3

Для подключения можно использовать проксирование стандарного ввода\вывода на удаленный хост используя NetCat:

ssh -o ProxyCommand='ssh 35.205.217.70 nc 10.132.0.3 22' 10.132.0.3

Т.к. я добавил в метаданные проекта ключ сгенерированный на рабочем хосте текущиим пользователем, я могу не указывать имя пользователя при подключениии, он используется автоматически. А все инстансы этого проекта по-умолчанию получают публичный ключ поего пользователя.
Для удобства использования можно связать адреса серверов с символьными именами. Сделать это можно через сервис DNS и т.п. сервисы рабочего места, но удобнее для этого использовать файл конфигурации ssh в домашнем каталоге:

~/.ssh/config:

   Host bastion
           Hostname 35.205.217.70
   Host inter-host-1
           Hostname 10.132.0.3
, и тогда команда приобретает вид:

ssh -o ProxyCommand='ssh bastion nc inter-host-1 22' inter-host-1

, хотя конечно в разных случаях могут быть наиболее полезны комбинации этих способов в сочитании с дополнительными функциями.

Дополнительное задание: настроить данное подключение, инициируемое командой вида "ssh inter-host-1".

При помощи упомянутого конфигурационного файла можно задать все нужные нам настройки подключения:

~/.ssh/config:

   Host bastion
           Hostname 35.205.217.70
   Host inter-host-1
           Hostname 10.132.0.3
           ProxyCommand ssh bastion -W %h:%p

, синтаксис ProxyCommand немного другой так как функционал nc с определенного момента встроен в ssh.
Благодаря приведенным настройкам можно подключиться к удаленному хосту командой "ssh inter-host-1". К тому же так можно настроить подключения через множество промежуточных хостов и сделать для себя процесс всё таким же простым и прозрачным,  как если бы хост был доступен напрямую.

2 Задание: добавить в репозиторий Infra файлы: setupvpn.sh и конфиг для openvpn: PartsUnlimited_test_bastion.ovpn

Выполнено.

#######################################################
