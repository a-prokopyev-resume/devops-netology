# [Домашнее задание](https://github.com/a-prokopyev-resume/sysadm-homeworks/tree/devsys10/02-git-02-base) к занятию [«Основы Git»](https://netology.ru/profile/program/git-dev-27/lessons/241717/lesson_items/1283980)

### Цель задания

В результате выполнения задания вы:

* научитесь работать с Git, как с распределённой системой контроля версий; 
* сможете создавать и настраивать репозиторий для работы в GitHub, GitLab и Bitbucket; 
* попрактикуетесь работать с тегами;
* поработаете с Git при помощи визуального редактора.

------

## Решение Задания 1. Знакомимся с GitLab и Bitbucket 

### GitLab

Создал учетные записи:
 * GitLab: https://gitlab.com/a-prokopyev-resume
 * Bitbucket: https://bitbucket.org/a-prokopyev-resume/

Зарегистрировал в обоих сервисах свой открытый ключ SSH. 

GitLab понравился тем, что в нем можно аутентифицироваться с помощью учетной записи Gmail, вход в которую защищен вторым фактором [WebAuthn](https://en.wikipedia.org/wiki/WebAuthn) U2F.
Кроме того сам GitLab тоже позволяет настроить свой второй фактор, тоже привязанный к ключу WebAuthn U2F, что делает его наиболее защищенным от несанкционированного использования из рассматриваемых сервисов.
Bitbucket не позволяет добавлять ключ WebAuthn U2F к своей учетной записи напрямую, но хотя бы позволяет аутентифицироваться с помощью учетной записи Gmail, где доступно использование ключей WebAuthn U2F.
Хуже всего с безопасностью в РФ обстоят дела при использовании новых учетных записей Github, потому что Github не работает через SSO аутентификацию учеткой Gmail, а для включения дополнительной аутентификации со встроенной в Github поддержкой WebAuthn U2F требуется сначала пройти проверку телефонного номера, отличного от +7.
Поэтому новые учетные записи Github являются наименее защищенными для пользователей из РФ.

Добавил remote для работы по протоколам SSH и HTTPS с новыми репозиториями:

    bitbucket   git@bitbucket.org:a-prokopyev-resume/devops-netology.git (fetch)
    bitbucket	git@bitbucket.org:a-prokopyev-resume/devops-netology.git (push)
    bitbucket-https	https://a-prokopyev-resume@bitbucket.org/andreyborue/devops-netology.git (fetch)
    bitbucket-https	https://a-prokopyev-resume@bitbucket.org/andreyborue/devops-netology.git (push)
    gitlab	git@gitlab.com:a-prokopyev-resume/devops-netology.git (fetch)
    gitlab	git@gitlab.com:a-prokopyev-resume/devops-netology.git (push)
    gitlab-https	https://gitlab.com/a-prokopyev-resume/devops-netology.git (fetch)
    gitlab-https	https://gitlab.com/a-prokopyev-resume/devops-netology.git (push)
    
Для origin репозитория Github у меня используется только SSH:
    
    origin  git@github.com:a-prokopyev-resume/devops-netology (fetch)                                                                                                                                                
    origin  git@github.com:a-prokopyev-resume/devops-netology (push)

Выполнил push локальной ветки main в новые репозитории командами: 
   `git push -u gitlab main` и `git push -u bitbucket main` 

Настроил публичную видимость репозиториев для ознакомления проверяющего преподавателя с результатом решения задания:
 * https://gitlab.com/a-prokopyev-resume/devops-netology
 * https://bitbucket.org/a-prokopyev-resume/devops-netology

## Решение задания 2. Теги

Представьте ситуацию, когда в коде была обнаружена ошибка — надо вернуться на предыдущую версию кода,
исправить её и выложить исправленный код в продакшн. Мы никуда не будем выкладывать код, но пометим некоторые коммиты тегами и создадим от них ветки. 

1. Создайте легковестный тег `v0.0` на HEAD-коммите и запуште его во все три добавленных на предыдущем этапе `upstream`.
1. Аналогично создайте аннотированный тег `v0.1`.
1. Перейдите на страницу просмотра тегов в GitHab (и в других репозиториях) и посмотрите, чем отличаются созданные теги. 
    * в GitHub — https://github.com/YOUR_ACCOUNT/devops-netology/releases;
    * в GitLab — https://gitlab.com/YOUR_ACCOUNT/devops-netology/-/tags;
    * в Bitbucket — список тегов расположен в выпадающем меню веток на отдельной вкладке. 

## Решение задания 3. Ветки 

Давайте посмотрим, как будет выглядеть история коммитов при создании веток. 

1. Переключитесь обратно на ветку `main`, которая должна быть связана с веткой `main` репозитория на `github`.
1. Посмотрите лог коммитов и найдите хеш коммита с названием `Prepare to delete and move`, который был создан в пределах предыдущего домашнего задания. 
1. Выполните `git checkout` по хешу найденного коммита. 
1. Создайте новую ветку `fix`, базируясь на этом коммите `git switch -c fix`.
1. Отправьте новую ветку в репозиторий на GitHub `git push -u origin fix`.
1. Посмотрите, как визуально выглядит ваша схема коммитов: https://github.com/YOUR_ACCOUNT/devops-netology/network. 
1. Теперь измените содержание файла `README.md`, добавив новую строчку.
1. Отправьте изменения в репозиторий и посмотрите, как изменится схема на странице https://github.com/YOUR_ACCOUNT/devops-netology/network 
и как изменится вывод команды `git log`.

## Решение задания 4. Упрощаем себе жизнь

Попробуем поработь с Git при помощи визуального редактора. 

1. В используемой IDE PyCharm откройте визуальный редактор работы с Git, находящийся в меню View -> Tool Windows -> Git.
1. Измените какой-нибудь файл, и он сразу появится на вкладке `Local Changes`, отсюда можно выполнить коммит, нажав на кнопку внизу этого диалога. 
1. Элементы управления для работы с Git будут выглядеть примерно так:

   ![Работа с гитом](img/ide-git-01.jpg)
   
1. Попробуйте выполнить пару коммитов, используя IDE. 

[По ссылке](https://www.jetbrains.com/help/pycharm/commit-and-push-changes.html) можно найти справочную информацию по визуальному интерфейсу. 

Если вверху экрана выбрать свою операционную систему, можно посмотреть горячие клавиши для работы с Git. 
Подробней о визуальном интерфейсе мы расскажем на одной из следующих лекций.

