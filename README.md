# Коротко о проекте

#### Проект - мини-игра с большим количеством участвующих токенов:
 - Ресурсы - обычные ERC-20 токены трех типов - ягода, золото, дерево.
 - Инструменты - ERC-1155 токены. Их можно крафтить с помощью определенного количества ресурсов - золота и дерева. На смарт инструментов отправляются токены ресурсов, которые затем сжигаются. Взамен пользователь получает токен инструмента.
 - Смарт добычи. Пользователь отправляет на него инструмент и токены ягод. Ягоды сжигаются. Инструмент лочится на определенное время. По окончанию этого времени пользователь может вывести обратно из контракта свой инструмент + награду - некоторое количество ресурсов. При этом у инструмента понижается параметр прочности.
 - Артефакты. ERC-1155 токены. Также могут выпасть пользователю с некоторой вероятностью в процессе добычи (предыдущий пункт). 
 - Смарт ремонта. Пользователь на него отправляет токены золота и указывает инструмент, который нужно отремонтировать.

Более подробное описание здесь - [BSC NFT-game_Requirements]

## Описание контрактов

### Artifacts

Коллекция ERC-1155, токены взаимозаменяемые. После деплоя необходимо вызвать функцию 
```
setToolsAddress(address)
```
, в параметры передать адрес развернутого контракта *Tools*. 

Контракт содержит функцию 
```
addNewArtifact(string memory name, uint256 _level)
```
, которую необходимо также вызвать после деплоя для добавления новых типов артефактов в коллекцию.

### Tools

Коллекция ERC-1155, токены невзаимозаменяемые. После деплоя необходимо вызвать функции
```
setArtifactsAddress(address artifactsAddress)
setMiningAddress(address miningAddress)
```
Для установления цены восстановления инструментов необходимо вызвать функцию 
```
function setRepairCost(uint256[] memory resourcesAmount)
```

Эта функцию принимает в себя массив целочисленных значений, где каждый индекс означает n + 1 индекс ресурсов (0 индекс - ресурс 1 типа), значение элемента по индексу означает количество необходимых ресурсов ([0, 100, 0] - 100 ресурсов 2 типа).

Для установления URI метаданных используются следующие функции
```
function setBaseURI(string calldata baseURI)
function setURI(uint256 toolType, string calldata newURI)
```

Функция для создания новых типов инструментов
```
function addTool(
        uint32 miningResource,
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost,
        uint32 rewardRate
    )
```
Принимает в себя следующие параметры:
 - ресурс, который этот инструменто может добывать
 - максимальная прочность инструмента
 - время добычи
 - трата энергии
 - трата прочности
 - количество добываемых ресурсов этим инструментом

После вызова этой функции создается событие 
```
event AddTool(uint256 toolType);
```
Событие содержит в себе тип добавленного инструмента.

Чеканить новые токены в этом контракте может только владелец, для этого вызываются следующие функции
```
function mint(
        address account,
        uint128 toolType,
        uint256 amount
    )

function mintBatch(
        address to,
        uint256[] calldata toolTypes,
        uint256[] calldata amounts,
        bytes calldata data
    )
```
Передаваемые параметры:
 - account(to) - адрес, по которому будет присвоен новый токен
 - toolType(toolTypes) - тип инструмента (для чеканки нескольких токенов передается массив типов)
 - amounts - количество токенов (во втором случае передается массив чисел)

Функция добавления новых рецептов для крафта
```
function createRecipe(
        uint256 toolType,
        uint256[] calldata resourcesAmount,
        uint256[] calldata artifactsAmount
    )
```
Принимает тип инструмента, количество ресурсов (нулевой индекс - первый тип ресурсов), количество артефактов. Генерирует событие 
```event CreateRecipe(uint256 recipeId)```, где передается id рецепта.

### Mining

Контракт добычи ресурсов.

После того, как игрок вызвал функцию ```startMining(uint256 toolId)```, генерируется событие 
```
event MiningStarted(address user, MiningSession session)
```
Событие передает адрес игрока и параметры сессии добычи (тип инструмента, время окончания добычи и тд).

Для завершения добычи ресурсов игрок вызывает функцию ```function endMining(uint256 toolId)```, функция генерирует событие 

```
event MiningEnded(address user, MiningSession session);
```

Бэкенду необходимо перехватить это событие и вызвать функцию распределения награды 
```
function setRewards(
        address user,
        uint256[] memory resourcesAmount,
        uint256[] memory artifactsAmount
    )
```

После этого игроку становится доступным вывод награды через функцию ```function getRewards()```

### Balcklist

Контракт черного списка.

Доступны 3 функции: проверка юзера на нахождение в черном списке, добавление и удаления.

```
    function check(address user) external view returns(bool)

    function addToBlacklist(address user) external onlyOwner 

    function removeFromBlacklist(address user) external onlyOwner
```

# Инструкция к деплою

1) Установить все зависимости через npm
```
npm i
```

2) Создать в корне проекта файл ```.env```
3) Заполнить файл конфигурации по шаблону
```
# hardhat.confing
REPORT_GAS=true

# BSC URL's
TESTNET_URL=https://data-seed-prebsc-1-s1.binance.org:8545/
MAINNET_URL= https://bsc-dataseed.binance.org/

BASE_URI=https://123.com/

PRIVATE_KEY=21dfd98724dd553c110e1959ad892a213113e1a4e137cec739d29af909b96ec
PUBLIC_KEY=0xf8139f9d650B321c07239Ef6290ce33cC6A4B507
API_KEY=IMGMLKIH9FB2ECPBABB771T3AF5WT87KAA

PANCAKE_ROUTER=0xD99D1c33F9fC3444f8101754aBC46c52416550D1
```
4) Запуск деплоя в тестовую сеть
```
npx hardhat run script/deploy.js --network testnet
```

