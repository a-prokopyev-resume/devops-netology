# Домашнее задание к занятию «Микросервисы: принципы»

## Задача 1: API Gateway 

Если рассматривать только основные базовые функциональные возможности API gateway, то многие популярные реализации API gateways в этом контексте отличаются обычно только своей лицензией.

Например, все из следующего списка: HAProxy, Tyk, KrakenD, Nginx, Kong, AWS API Gateway, Azure Gateway  поддерживают:
* Маршрутизацию запросов
* Аутентификацию
* Терминацию HTTPS

Платными обычно являются облачные реализации либо расширенные редакции on-premisce вариантов.

Преимущества, которые могут давать API Gateways:
* Reliable Service Delivery
* Governance
* Enhanced Security
* API Usage Monitoring
* Simplified Development, Deployment, and Management
* Improved Scalability and Availability
* Efficient Management of Incoming Requests
* Caching 
* Load Balancing
* Developer Portal

Но некоторые из них всё же они могут привнести с собой и потенциальные риски и недостатки:
* Vulnerability exploits
* Authorization errors
* Authentication issues
* Denial-of-service attacks
* Insufficient visibility
* Centralized authentication
* API-specific threats or business logic vulnerabilities
* API traffic and management
* API security risks

Разные реализации могут отличаться своей масштабируемостью, производительностью и другими некоторыми специфичными особенностями.

Наиболее популярным бесплатным open-source решением, вероятно, является Nginx.
Ещё IMHO очень интересным, функциональным, высокопроизводительным, хорошо масштабируемым и гибким вариантом является HAProxy. Облачные варианты могут быть интересны тем, кто хостится в соответствующих облаках и не хочет заниматься поддержкой и настройкой API gateway самостоятельно.

Я бы выбрал Nginx и/или HAProxy.

Полезные линки с описаниями features различных API gateways:

* https://www.akamai.com/glossary/what-is-api-gateway-security
* https://nonamesecurity.com/learn/what-is-api-gateway/
* https://www.softwareag.com/en_corporate/resources/api/article/api-gateway.html
* https://konghq.com/learning-center/api-gateway/what-is-an-api-gateway
* https://mivocloud.com/blog/HAProxy-Load-balancer-for-reliability-and-scalability-of-your-server


## Задача 2: Брокер сообщений

|  Features  | Kafka  | Redpanda |
|------------|--------|--------- |
| Throughput  | High | High, can exceed Kafka’s performance |
| Data retention | Infinite log-based streaming  | Segment-based data deletion |
| Storage management  | Requires significant storage, risk of exhaustion  |  Efficient replication and buffer cache, less storage use |
| Ease of use  | Complex setup (requires JVM, ZooKeeper)  | Simplified setup (no JVM, ZooKeeper dependencies) |
| Data replication  | Triplicate replication for high availability  | Consensus replication, less storage footprint |

https://redpanda.com/guides/kafka-alternatives/kafka-throughput

Оба варианта соответствуют требованиям задачи:
- поддержка кластеризации для обеспечения надёжности,
- хранение сообщений на диске в процессе доставки,
- высокая скорость работы,
- поддержка различных форматов сообщений,
- разделение прав доступа к различным потокам сообщений,
- простота эксплуатации.

Но я выбрал бы Redpanda, потому что судя по описанию [Redpanda обладает следующими преимуществами](https://github.com/redpanda-data/redpanda/):
```
Redpanda is a streaming data platform for developers. Kafka® API-compatible. ZooKeeper® free. JVM free. We built it from the ground up to eliminate complexity common to Apache Kafka, improve performance by up to 10x, and make the storage architecture safer, and more resilient. The simpler devex lets you focus on your code (instead of fighting Kafka) and develop new use cases that were never before possible. The business benefits from a significantly lower total cost and faster time to market. A new platform that scales with you from the smallest projects to petabytes of data distributed across the globe!
```

Ещё раз подчеркну следующие преимущества Redpanda по сравнению с Kafka:
* Совместимость с Kafka API, а значит, замену сделать относительно несложно
* Не использует ZooKeeper
* Не использует JVM
* Производительно выше до 10 раз
* Более безопасная архитектура хранилища данных
* [Более эластичная архитектура](https://redpanda.com/blog/producer-config-deep-dive), на Kafka жалуются, что у неё сильно падает производительность во время падения отдельных узлов
* В итоге Redpanda позволяет сосредоточиться на своём бизнесе, а не бороться с проблемами уже в каком-то смысле устаревающей Kafka
* Позволяет обрабатывать петабайты геораспределённых данных

```
Redpanda is designed to be more resilient than Kafka in terms of handling broker crashes due to its default configuration, which requires messages to be replicated and fsynced to the majority of brokers responsible for the partition in the cluster before they are considered acknowledged and made visible to readers. This ensures that messages are durable in case of broker crashes, providing a higher level of fault tolerance compared to Kafka's default configuration, which does not require messages to be fsynced before they are acknowledged
```

Относительно соответствия Redpanda решаемой задаче:

* https://quix.io/blog/redpanda-vs-kafka-comparison
* https://docs.redpanda.com/current/get-started/architecture/
* https://docs.redpanda.com/current/develop/transactions/

IMHO, выбор очевиден.


### The Beginning of the Copyright Notice:

The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
 born on December 20, 1977 resident of the city of Kurgan, Russia;  
Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91  
Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007  
Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04  
Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.  
Contact of the AUTHOR: a.prokopyev.resume at gmail dot com  

All source code and other content contained in this file is protected by copyright law.
This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html

THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:
Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments). Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 

ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee   is STRONGLY PROHIBITED to use this file by any method.
