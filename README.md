#######################################################

# terraform-2. Домашнее задание #9.
## Инфраструктура с двумя серверами.
В рамках данного ДЗ нужно создать две ВМ(инстанса), поэтому были созданы два дополнительных образа при помощи packer: reddit-app-base и reddit-db-base. Для создания образов было использовано два новых шаблона packer: packer/app.json и packer/db.json. 
С использованием наработок прошлого ДЗ конфигурация terraform была разбита на четыре файла: 
* app.tf - содержит конфигурацию хоста приложения на основе образа reddit-app-base;
* db.tf - содержит конфигурацию хоста СУБД на основе образа reddit-db-base;
* vpc.tf - содержит конфигурацию правил фаервола;
* main.tf - содержит только конфигурацию провайдера.
## Использование модулей в terraform.
### Модули приложения и БД.
Далее данная конфигурация инфраструктуры из двух серверов была реализована с использованием модулей. 
Для этого в каталоге terraform были созданы каталоги modules/db и modules/app в которых описание инфраструктуры серверов было организовано с помощью набора файлов: main.tf, variables.tf, outputs.tf. По одному набору с соответствующим наполнением для каждого модуля. Для того чтобы файлы конфигурации из корневого каталога terraform не применялись и не мешали работе новой структуры с использованием модулей файлы в основной директории были переименованы:
app.tf --> app.tf-old
db.tf --> db.tf-old
outputs.tf --> outputs.tf-old
В файле vpc.tf ещё на предыдущем шаге было оставлено только общее для всех правило фаервола для открытия доступа по ssh, поэтому его изменение пока не требуется. Файл main.tf помимо определения провайдера был дополнен инклудами (секциями вызова) модулей которые были созданы. 
После инициации данных модулей командой "terraform get", была изменена ссылка на выходную переменную app_external_ip в файле корневой конфигурации выходных переменных: outputs.tf. Ссылка изменена с прямой: ```google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip``` 
на опосредованую ссылку на переменную в модуле:
```module.app.app_external_ip```,
т.к. прямая ссылка больше не действительна из-за отсутствия в результирующей корневой конфигурации такого ресурса как google_compute_instance.app. 
После этого была развернута инфраструктура при помощи данной модульной конфигурации.
## Самостоятельная работа.
### Модуль фаервола.
Далее конфигурация terraform была дополнена ещё одним модулем: vpc - для конфигурирования правил фаервола. Для этого был создан каталог modules/vpc и в него скопировано содержимое файла vpc.tf из корневого каталога в файл modules/vpc/main.tf. После чего расширение файла в корне было изменено чтобы terraform его в работе не учитывал:
vpc.tf --> vpc.tf-old
После создания данного модуля и применения его в основной конфигурации, инфраструктура была удачно собрана с использованием трех модулей: module.app, module.db, module.vpc. Как и на предыдущем шаге, правило фаервола для доступа по ssh появилось, и на созданные инстансы по внешним адресам можно зайти по ssh.
### Параметризация модулей.
Далее в модуль vpc была введена input-переменная определяющая диапазон ip-адресов которым разрешен доступ по ssh к создаваемым истансам.
С целью самопроверки было произведено три итерации по изменению данной переменной в файле корневой конфигурации variables.tf:
* source_ranges = ["my.work.ip.addr/32"] - , где my.work.ip.addr -это внешний ip-адрес на рабочем месте. После применения этой конфигурации доступ к инстансам по ssh остался только с рабочего места, а с домашнего компьютера порт был недоступен;
* source_ranges = ["my.home.ip.addr/32"] - , где my.home.ip.addr -это внешний ip-адрес на домашнем компьютере. После применения этой конфигурации доступ к инстансам по ssh остался только с домашнего компьютера (точнее внешнего ip-адреса домашнего роутера), а с рабочего компьютера порты ssh на созданных инстансах были недоступны;
* source_ranges = ["0.0.0.0/0"] - После применения этой конфигурации доступ к инстансам по ssh был восстановлен для любого источника.
Можно было бы конечно удалить задание значения данной переменной из variables.tf и эфект был бы тот же, т.к. это значение переменной является дефолтным. Но для обеспечения удобной повторной применимости конфигурации для разных оклужений удобнее оставить определение переменной даже в дефолтное значение.
### Переиспользование модулей.
Последним шагом основного задания были созданы две конфигурации для stage и production инфраструктур, для чего корневые конфигурационные файлы были перенесены в каталоги stage/ и prod/ соответственно. Пути к модулям в файлах stage/main.tf и prod/main.tf были изменены, после чего конфигурации стало возможно применять командами terraform-а из соответвующих каталогов.
Файлы main.tf, outputs.tf, terraform.tfvars, variables.tf из корневого каталога terraform были удалены, так же как и стейт файлы корневой конфигурации terraform-a и файлы *-old созданные на прошлых шагах.
Т.о. после инициализации конфигураций в каталогах stage и prod структура каталога terraform приняла вид:
```./
├── files
│   ├── deploy.sh
│   └── puma.service
├── modules
│   ├── app
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── db
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       └── variables.tf
├── prod
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   ├── terraform.tfvars
│   └── variables.tf
└── stage
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfvars
    └── variables.tf
```
Некоторые значения параметров конфигурации были заменены на переменные (параметризированы):
* instance_app_name - переменная для имени инстанса приложения, чтобы можно было разделить stage и prod сервера приложений по именам;
* instance_db_name - переменная для имени инстанса БД, чтобы можно было разделить stage и prod сервера БД по именам;
* ssh_fwrule_name - переменная имени для правила фаервола разрешающего доступ к инстансам по ssh, правила для stage и prod разные значит и имена должны быть разные;
* machine_type_app и machine_type_db - переменные для задания типа ВМ в зависимости от назначения и сферы применения;
* puma_allow_rule_name и mongo_allow_rule_name - переменные для разделения имен правил фаервола для stage и prod серверов;
* app_external_if_name - имя внешнего интерфейса сервера приложений.
Так же в качестве переменной "network_name" было заведено имя сети во всех модулях, и при желании можно параметрами задать разные сети для stage и prod серверов.
На данном этапе изменения были закоммичены в ветку terraform-2. Перед коммитом были созданы файлы terraform.tfvars.example вместо файлов terraform.tfvars не попадающих в коммит.
Далее были созданы ещё два ресурса типа storage-bucket с помощью terraform, для чего в каталог terraform было добавлено три файла:
* storage-bucket.tf - с описанием ресурсов создаваемых баккетов;
* variables.tf - с описанием переменных использованных в storage-bucket.tf;
* terraform.tfvars - со значениями переменных, в репозитории есть образец этого файла: terraform.tfvars.example.
После успешного создания ресурсы были удалены.

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
