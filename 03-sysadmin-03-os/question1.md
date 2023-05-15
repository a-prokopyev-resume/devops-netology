# Вопрос про прерывание выполнения команд после другой последовательности команд, объединенных логическими операторами, при использовании команды set -e;

Посмотрим описание команды `set -x`:

```
root@kube:~# man bash | grep 'set \[+ab' -A 20 | grep '\-e' -A 1
              -e      Exit immediately if a pipeline (which may consist of a single simple command), a list, or a compound command (see SHELL GRAMMAR above), exits with a non-zero status.  The shell does
                      not exit if the command that fails is part of the command list immediately following a while or until keyword, part of the test following the if or elif reserved words, part of  any
--
                      !.  If a compound command other than a subshell returns a non-zero status because a command failed while -e was being ignored, the shell does not exit.  A trap on ERR,  if  set,  is
                      executed before the shell exits.  This option applies to the shell environment and each subshell environment separately (see COMMAND EXECUTION ENVIRONMENT above), and may cause sub‐
--
                      If a compound command or shell function executes in a context where -e is being ignored, none of the commands executed within the compound command or function body will be  affected
                      by  the -e setting, even if -e is set and a command returns a failure status.  If a compound command or shell function sets -e while executing in a context where -e is ignored, that
                      setting will not have any effect until the compound command or the command containing the function call completes.
```

Вариант описания на русском языке можно найти на странице:

https://www.opennet.ru/man.shtml?topic=bash&category=1
```
-e

    Немедленно завершать работу, если простая команда

    (см. раздел "СИНТАКСИС КОМАНД" ранее)

    завершает работу с ненулевым статусом выхода. Работа командного интерпретатора не

    завершается, если закончившаяся неудачно команда является частью

    цикла until или while,

    частью оператора if, частью списка && или ||, или

    если к статусу выхода команды применяется отрицание с помощью оператора !.
```

Таким образом, `set -e` прерывает последовательность команд, объединенных безусловным разделителем `;`, если одна из команд возвращает ненулевой код возврата. Примеры:
```
bash -lc "set -e; false; echo Second Command" # Вторая команда не выполнилась
# Команда false с точки зрения set -e выдает ошибку из-за своего ненулевого кода возврата.

bash -lc "set -e; true; echo Second Command" # А в данном случае вторая команда выполнилась нормально.
Second Command
```

И не прерывает команды после цепочки команд, объединенных логическими операторами `||` и `&&`.

Пример для оператора логического "ИЛИ" (`||`):
```
bash -lc "set -e; false || false; echo 'Execution continued'" # <===
# Почему прервалось? Ведь в документации сказано, что якобы команды, объединенные логическими операторами не влияют?
bash -lc "set -e; true || false; echo 'Execution continued'"
Execution continued
bash -lc "set -e; false || true; echo 'Execution continued'"
Execution continued
```

С другой стороны для логического "И" (`&&`) происходит что-то непонятное:
```
bash -lc "set -e; false && false; echo 'Execution continued'"
Execution continued
bash -lc "set -e; true && false; echo 'Execution continued'" # <===
# Почему прервалось? Ведь в документации сказано, что якобы команды, объединенные логическими операторами не влияют?
bash -lc "set -e; false && true; echo 'Execution continued'"
Execution continued
```
Непонятно, почему прервались команды после  `false || false;` и после `true && false;`, отмеченные комментарием # <===
Возможно все же влияет код возврата последней команды в логической цепочке?

