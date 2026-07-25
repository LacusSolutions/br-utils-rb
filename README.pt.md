![cpf-utilities para Ruby](https://br-utils.vercel.app/img/cover_cpf-utils.jpg)

> 🌎 [Access documentation in English](./README.md)

Kit em Ruby para formatar, gerar e validar CPF (Cadastro de Pessoa Física). Envolve [`cpf-fmt`](https://rubygems.org/gems/cpf-fmt), [`cpf-gen`](https://rubygems.org/gems/cpf-gen) e [`cpf-val`](https://rubygems.org/gems/cpf-val) em uma única classe fachada (`CpfUtils`).

## Recursos

- ✅ **API unificada**: Helpers de classe `CpfUtils.format` / `.generate` / `.is_valid` (aliases de `CpfUtils::DEFAULT`); `DEFAULT` mutável para ajustes compartilhados
- ✅ **Acesso em dois níveis**: Prefira `CpfUtils::CpfFormatter` / `CpfGenerator` / `CpfValidator` para as classes principais; Options, helpers e erros ficam em `CpfUtils::CpfFmt` / `CpfGen` / `CpfVal` (os irmãos na raiz `CpfFmt` / `CpfGen` / `CpfVal` continuam funcionando)
- ✅ **CPF numérico**: Formatar, gerar e validar CPF de 11 dígitos (`XXX.XXX.XXX-XX`)
- ✅ **Instância reutilizável**: Classe `CpfUtils` com configurações padrão opcionais (opções ou instâncias do formatador/gerador; instância do validador)
- ✅ **Entrada flexível**: `#format` e `#is_valid` aceitam `String` ou `Array` de strings (elementos concatenados na ordem)
- ✅ **Sobrescritas por chamada**: Padrões da instância mais um `Hash`/instância `*Options` por chamada **ou** sobrescritas por palavra-chave em `#format` / `#generate` (não ambos); `#is_valid` recebe apenas a entrada
- ✅ **Tratamento de erros**: Erros dos componentes propagam inalterados; esta gem define `CpfUtils::TypeMismatchError` e `CpfUtils::InvalidArgumentCombinationError` para uso indevido da API

## Instalação

Instale a gem diretamente:

```bash
gem install cpf-utilities
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cpf-utilities'
```

Isso instala **`cpf-utilities`** junto com [`cpf-fmt`](https://rubygems.org/gems/cpf-fmt), [`cpf-gen`](https://rubygems.org/gems/cpf-gen) e [`cpf-val`](https://rubygems.org/gems/cpf-val). Você **não** precisa de `gem install` / linhas `gem` separados para os pacotes componentes ao usar **`cpf-utilities`**.

## Require

```ruby
require 'cpf-utilities'
```

## Início rápido

Uso básico com helpers de classe (aliases de `CpfUtils::DEFAULT`):

```ruby
require 'cpf-utilities'

cpf = '12345678909'

CpfUtils.format(cpf)                 # => "123.456.789-09"
CpfUtils.format(cpf, hidden: true)   # => "123.***.***-**"
CpfUtils.format(                     # => "123456789_09"
  cpf,
  dot_key: '',
  dash_key: '_'
)

CpfUtils.generate                       # => ex.: "47844241055" (11 dígitos numéricos)
CpfUtils.generate(format: true)         # => ex.: "478.442.410-55"
CpfUtils.generate(prefix: '528250911')  # => ex.: "52825091138"

CpfUtils.is_valid('12345678909')      # => true
CpfUtils.is_valid('123.456.789-09')   # => true
CpfUtils.is_valid('12345678900')      # => false
```

## Utilização

Você pode trabalhar destas formas equivalentes:

1. **`CpfUtils.format` / `.generate` / `.is_valid`** — helpers de classe para chamadas rápidas (encaminham para `DEFAULT`).
2. **`CpfUtils::DEFAULT`** — singleton compartilhado mutável (o mesmo objeto usado pelos helpers de classe).
3. **`CpfUtils.new`** — instância configurável com padrões compartilhados entre formatar, gerar e validar.
4. **Classes principais sob `CpfUtils`** — `CpfUtils::CpfFormatter`, `CpfUtils::CpfGenerator`, `CpfUtils::CpfValidator`.
5. **Módulos aninhados do pacote** — Options, helpers, erros e tipos via `CpfUtils::CpfFmt` / `CpfGen` / `CpfVal` (ex.: `CpfUtils::CpfFmt::CpfFormatterOptions`, `CpfUtils::CpfFmt.cpf_fmt`).
6. **Módulos irmãos na raiz** (ainda suportados) — `CpfFmt`, `CpfGen`, `CpfVal` inalterados.

Todas as abordagens expõem as mesmas opções e comportamento. Para tabelas de opções exaustivas e detalhes específicos de cada componente, consulte o README de cada [pacote incluído](#pacotes-incluídos).

### Opções do formatador

Em `#format(cpf_input, options = nil, **keywords)`, todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | Se `true`, mascara dígitos entre `hidden_start` e `hidden_end` com `hidden_key` |
| `hidden_key` | `String` | `'*'` | Caractere(s) usados para substituir os dígitos mascarados |
| `hidden_start` | `Integer` | `3` | Índice inicial (0–10, inclusivo) do intervalo a ocultar |
| `hidden_end` | `Integer` | `10` | Índice final (0–10, inclusivo) do intervalo a ocultar |
| `dot_key` | `String` | `'.'` | Delimitador de ponto (ex.: em `123.456.789`) |
| `dash_key` | `String` | `'-'` | Delimitador de hífen (ex.: antes dos dígitos verificadores `…-09`) |
| `escape` | `Boolean` | `false` | Se `true`, escapa caracteres especiais HTML no resultado |
| `encode` | `Boolean` | `false` | Se `true`, codifica o resultado para URL (similar ao `encodeURIComponent` do JavaScript) |
| `on_fail` | `Proc` / invocável | retorna `''` | Callback quando o tamanho da entrada sanitizada ≠ 11; o retorno é usado como resultado |

### Opções do gerador

Em `#generate(options = nil, **keywords)`, todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | Se `true`, retorna o CPF gerado no formato padrão (`000.000.000-00`) |
| `prefix` | `String` | `''` | String inicial parcial (0–9 dígitos). Não-dígitos são removidos; os caracteres faltantes são gerados e os dígitos verificadores calculados. Prefixos com mais de 9 dígitos são truncados silenciosamente. |

Regras do prefixo: a base (primeiros 9 dígitos) não pode ser todos zeros; 9 dígitos repetidos (ex.: `999999999`) também não são permitidos.

### Helpers de classe (`CpfUtils.format` / `.generate` / `.is_valid`)

Esses métodos de classe são aliases dos mesmos métodos em `CpfUtils::DEFAULT`. Prefira-os para chamadas pontuais:

```ruby
CpfUtils.format('12345678909')
CpfUtils.generate(format: true)
CpfUtils.is_valid('12345678909')
```

### `CpfUtils::DEFAULT` (instância padrão)

`CpfUtils::DEFAULT` é o singleton pré-construído e **mutável** por trás dos helpers de classe (paridade com o export padrão do JS / `cpf_utils` do Python). Mutá-lo afeta chamadas seguintes a `CpfUtils.format` / `.generate` / `.is_valid`; instâncias `CpfUtils.new` personalizadas permanecem independentes:

```ruby
CpfUtils::DEFAULT.formatter = { dash_key: '|' }
CpfUtils.format('12345678909')   # => "123.456.789|09"

custom = CpfUtils.new
custom.format('12345678909')     # => "123.456.789-09" (não afetado)
```

Métodos de instância em `DEFAULT` (e em qualquer instância de `CpfUtils`):

- **`#format(cpf_input, options = nil, **keywords)`**: Formata uma string CPF ou array de strings. Delega ao formatador interno. A entrada deve ter 11 dígitos (após sanitização); caso contrário, `on_fail` é usado.
- **`#generate(options = nil, **keywords)`**: Gera um CPF válido. Delega ao gerador interno.
- **`#is_valid(cpf_input)`**: Retorna `true` se o CPF for válido. Delega ao validador interno. Sem opções por chamada — o validador de CPF não tem nenhuma.

### `CpfUtils` (classe)

Para formatador, gerador ou validador padrão personalizados, crie sua própria instância:

```ruby
require 'cpf-utilities'

utils = CpfUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { format: true, prefix: '123' }
)

utils.format('47844241055')        # => "478.###.###-##"
utils.generate                     # => ex.: "123.456.789-09"
utils.is_valid('123.456.789-09')   # => true

# Acessar ou substituir instâncias internas
utils.formatter   # => CpfFmt::CpfFormatter
utils.generator   # => CpfGen::CpfGenerator
utils.validator   # => CpfVal::CpfValidator
```

- **`CpfUtils.new(settings = nil, **keywords)`**: Configurações opcionais. Passe um `Hash` de settings com as chaves `:formatter`, `:generator` e/ou `:validator`, **ou** as mesmas chaves como argumentos nomeados — não ambos (passar ambos lança `CpfUtils::InvalidArgumentCombinationError`). Para `:formatter` / `:generator`, cada valor pode ser uma instância de componente, uma instância `*Options` (armazenada por referência — mutá-la depois afeta chamadas subsequentes sem sobrescrita por chamada), um `Hash` de opções, ou omitido/`nil` para os padrões. Para `:validator`, passe uma instância de `CpfVal::CpfValidator`, `nil` ou um objeto duck-typed — **não** um `Hash` de opções (não existe `CpfValidatorOptions`).
- **`#format(cpf_input, options = nil, **keywords)`**: Igual à instância padrão; opções por chamada sobrescrevem os padrões do formatador apenas nessa chamada. Passe um `Hash`/`CpfFmt::CpfFormatterOptions` **ou** sobrescritas por palavra-chave — não ambos.
- **`#generate(options = nil, **keywords)`**: Igual à instância padrão; opções por chamada sobrescrevem os padrões do gerador. Passe um `Hash`/`CpfGen::CpfGeneratorOptions` **ou** sobrescritas por palavra-chave — não ambos.
- **`#is_valid(cpf_input)`**: Igual à instância padrão. Sem opções por chamada.
- **`#formatter`**, **`#generator`**, **`#validator`**: Acessores (getters e setters) dos componentes internos. Os setters aceitam as mesmas formas do construtor. Para alterar uma única opção do formatador/gerador sem substituir a instância, mute as opções do componente (ex.: `utils.formatter.options.hidden = true`).

Padrões da instância e sobrescritas por chamada:

```ruby
require 'cpf-utilities'

utils = CpfUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { format: true }
)

cpf = '12345678909'

utils.format(cpf)                 # mascarado (padrões do formatador da instância)
utils.format(cpf, hidden: false)  # só nesta chamada: sem máscara
utils.generate(format: false)     # só nesta chamada: saída compacta
utils.is_valid(cpf)               # => true
```

As opções também podem ser passadas como `Hash` (ou instância de opções) em `#format` / `#generate` — sem sobrescritas por palavra-chave:

```ruby
utils.format(cpf, { dash_key: '|' })
utils.generate({ prefix: '12345', format: true })
```

### Usando classes de componente e módulos aninhados

Caminhos preferidos após `require 'cpf-utilities'`:

```ruby
require 'cpf-utilities'

# Classes principais na raiz da fachada
formatter = CpfUtils::CpfFormatter.new(hidden: true)
generator = CpfUtils::CpfGenerator.new(format: true)
validator = CpfUtils::CpfValidator.new

formatter.format('47844241055')   # => "478.***.***-**"

# Options, helpers e erros sob os módulos aninhados do pacote
options = CpfUtils::CpfFmt::CpfFormatterOptions.new(dash_key: '|')
CpfUtils::CpfFmt.cpf_fmt('12345678909')   # => "123.456.789-09"

begin
  CpfUtils::CpfFmt.cpf_fmt(12_345)
rescue CpfUtils::CpfFmt::TypeMismatchError
  # tipo de entrada incorreto
end
```

Os irmãos na raiz continuam suportados (os mesmos objetos que os aninhados):

```ruby
CpfFmt.cpf_fmt('12345678909', dash_key: '|')   # => "123.456.789|09"
CpfGen.cpf_gen(format: true)                   # => ex.: "478.442.410-55"
CpfVal.cpf_val('12345678909')                  # => true
CpfFmt::CpfFormatter.new(hidden: true)
```

Consulte [`cpf-fmt`](../cpf-fmt/README.pt.md), [`cpf-gen`](../cpf-gen/README.pt.md) e [`cpf-val`](../cpf-val/README.pt.md) para detalhes completos de opções e erros.

## API

### Exportações

Após `require 'cpf-utilities'`:

- **`CpfUtils`**: Classe fachada para criar uma instância com configurações padrão opcionais de formatador, gerador e validador.
- **`CpfUtils.format` / `.generate` / `.is_valid`**: Helpers de classe que encaminham para `CpfUtils::DEFAULT`.
- **`CpfUtils::DEFAULT`**: Instância pré-construída mutável de `CpfUtils` (o mesmo objeto usado pelos helpers de classe).
- **`CpfUtils::VERSION`**: String da versão da gem.
- **Atalhos das classes principais**: `CpfUtils::CpfFormatter`, `CpfUtils::CpfGenerator`, `CpfUtils::CpfValidator` (os mesmos objetos das classes irmãs).
- **Módulos aninhados do pacote**: `CpfUtils::CpfFmt`, `CpfUtils::CpfGen`, `CpfUtils::CpfVal` — superfície completa do irmão (Options, helpers, erros, tipos). Options/helpers/erros **não** são aliasados na raiz de `CpfUtils`.
- **Módulos irmãos na raiz** (ainda suportados): `CpfFmt`, `CpfGen`, `CpfVal` — os mesmos objetos que os aninhados.

### Erros e exceções

`CpfUtils` define apenas erros de uso indevido da API para as regras de argumentos desta gem. Erros de componentes são lançados pelos pacotes incluídos e propagam inalterados.

#### Definidos por `cpf-utilities`

Os erros definidos por esta gem são apenas de **uso indevido da API** (tipo incorreto ou combinação inválida de argumentos). Todo erro customizado inclui o módulo marcador `CpfUtils::Error`. Esta gem **não** define `CpfUtils::DomainError` nem folhas de domínio — falhas de domínio vêm apenas dos [pacotes incluídos](#propagados-dos-pacotes-incluídos) e mantêm os namespaces desses pacotes (`CpfFmt::…`, `CpfGen::…`, `CpfVal::…`).

`rescue CpfUtils::Error` captura **apenas** erros que esta gem lança. **Não** captura erros de componentes que propagam inalterados.

##### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|--------|----------|-----------|---------------------|
| `CpfUtils::InvalidArgumentCombinationError` | `CpfUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (+ `include CpfUtils::Error`) | Uso indevido da API | Construtor: `Hash` de settings não-`nil` com qualquer argumento nomeado não-`nil`; ou `#format`/`#generate`/helpers de classe: `Hash`/instância `*Options` de options não-`nil` com qualquer argumento nomeado não-`nil` |
| `CpfUtils::TypeMismatchError` | `CpfUtils::TypeMismatchError < TypeError < StandardError` (+ `include CpfUtils::Error`) | Uso indevido da API | Argumento `settings` não-`nil` de `CpfUtils.new` não é um `Hash` |

##### `CpfUtils::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro customizado que esta gem lança via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é lançado:** Nunca é lançado diretamente; incluído em todo erro customizado que esta gem lança.
- **Exemplo:** N/A
- **Como resgatá-lo:**

```ruby
rescue CpfUtils::Error
  # TypeMismatchError e InvalidArgumentCombinationError apenas desta gem
  # (não CpfFmt::*, CpfGen::* nem CpfVal::*)
```

##### `CpfUtils::TypeMismatchError`

- **Herança:** `CpfUtils::TypeMismatchError < TypeError < StandardError` (inclui `CpfUtils::Error`)
- **Categoria:** Uso indevido da API — o chamador passou um valor do tipo errado.
- **Quando é lançado:** Quando `CpfUtils.new` recebe um argumento `settings` não-`nil` que não é um `Hash`.
- **Exemplo:**

```ruby
CpfUtils.new('not-a-hash')   # lança CpfUtils::TypeMismatchError
CpfUtils.new(false)          # lança CpfUtils::TypeMismatchError (false é não-nil)
```

- **Como resgatá-lo:**

```ruby
rescue CpfUtils::TypeMismatchError
  # violação de contrato de tipo desta gem

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta gem
```

##### `CpfUtils::InvalidArgumentCombinationError`

- **Herança:** `CpfUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (inclui `CpfUtils::Error`)
- **Categoria:** Uso indevido da API — o chamador misturou padrões de argumentos mutuamente exclusivos.
- **Quando é lançado:** Quando `CpfUtils.new` recebe ao mesmo tempo um `Hash` de settings não-`nil` e qualquer argumento nomeado não-`nil` (`formatter:`, `generator:`, `validator:`); ou quando `#format`, `#generate` ou os helpers de classe recebem ao mesmo tempo um `Hash`/instância `*Options` de options não-`nil` e qualquer argumento nomeado não-`nil`. `#is_valid` não tem caminho de options e não lança este erro.
- **Exemplo:**

```ruby
CpfUtils.new({ formatter: { hidden: true } }, generator: { format: true })
# lança CpfUtils::InvalidArgumentCombinationError

CpfUtils.format('12345678909', { hidden: true }, dash_key: '|')
# lança CpfUtils::InvalidArgumentCombinationError
```

- **Como resgatá-lo:**

```ruby
rescue CpfUtils::InvalidArgumentCombinationError
  # combinação de assinatura inválida desta gem

rescue ArgumentError
  # erros nativos de argumento, incluindo InvalidArgumentCombinationError desta gem
```

##### Granularidade de rescue

Cada nível é mostrado como exemplo isolado (não os una numa única escada de `rescue` — um handler nativo amplo tornaria as cláusulas mais estreitas inalcançáveis).

```ruby
require 'cpf-utilities'

# 1) Uma classe nativa — captura erros de uso indevido daquele tipo,
#    inclusive outros TypeError/ArgumentError já tratados no código do consumidor.
begin
  CpfUtils.new('not-a-hash')
rescue TypeError
  # CpfUtils::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)
end

begin
  CpfUtils.new({ formatter: { hidden: true } }, generator: { format: true })
rescue ArgumentError
  # CpfUtils::InvalidArgumentCombinationError e qualquer outro ArgumentError (da biblioteca ou não)
end
```

```ruby
require 'cpf-utilities'

# 2) DomainError dos pacotes — esta gem não define DomainError; falhas de domínio
#    vêm dos pacotes de componente e mantêm esses namespaces (ex.: CpfFmt).
begin
  CpfUtils.new.format('12345678909', hidden_start: -1)
rescue CpfFmt::DomainError
  # CpfFmt::OutOfRangeError, CpfFmt::ValidationError e outras subclasses de DomainError
end
```

```ruby
require 'cpf-utilities'

# 3) CpfUtils::Error — captura tudo o que esta gem lança, independentemente da ancestralidade nativa.
#    Não captura erros CpfFmt::*, CpfGen::* nem CpfVal::*.
begin
  CpfUtils.new('not-a-hash')
rescue CpfUtils::Error
  # todo erro customizado que inclui CpfUtils::Error
end
```

```ruby
require 'cpf-utilities'

# 4) Classe folha específica — captura apenas aquele modo de falha.
begin
  CpfUtils.new('not-a-hash')
rescue CpfUtils::TypeMismatchError
  # apenas CpfUtils::TypeMismatchError
end
```

#### Propagados dos pacotes incluídos

Os erros de componentes mantêm os namespaces dos pacotes e propagam inalterados pela fachada (e pelas APIs aninhadas / irmãos na raiz). Cada pacote também expõe um módulo marcador `*::Error` para rescue em toda a biblioteca. **Dados** de CPF inválidos em `#is_valid` retornam `false` (sem raise de domínio). Falha de comprimento na formatação **não** é lançada por `#format` — é entregue a **`on_fail`** como `CpfFmt::InvalidLengthError` (`on_fail` padrão retorna `''`).

##### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|--------|----------|-----------|---------------------|
| `CpfFmt::InvalidArgumentCombinationError` | `ArgumentError` (+ `include CpfFmt::Error`) | Uso indevido da API | Instância/`Hash` de `options` e qualquer argumento nomeado não-`nil` em `CpfFormatter` / `cpf_fmt` |
| `CpfFmt::InvalidLengthError` | `CpfFmt::DomainError` | Erro de domínio | Comprimento sanitizado ≠ 11 — **passado a `on_fail`**, não lançado por `#format` |
| `CpfFmt::OutOfRangeError` | `CpfFmt::DomainError` | Erro de domínio | `hidden_start` / `hidden_end` fora de `0`–`10` |
| `CpfFmt::TypeMismatchError` | `TypeError` (+ `include CpfFmt::Error`) | Uso indevido da API | Entrada de CPF ou opção do formatador com tipo errado (ou retorno de `on_fail` que não é `String`) |
| `CpfFmt::ValidationError` | `CpfFmt::DomainError` | Erro de domínio | `hidden_key` / `dot_key` / `dash_key` contém caractere proibido |
| `CpfGen::InvalidArgumentCombinationError` | `ArgumentError` (+ `include CpfGen::Error`) | Uso indevido da API | Instância/`Hash` de `options` e qualquer argumento nomeado não-`nil` em `CpfGenerator` / `cpf_gen` |
| `CpfGen::TypeMismatchError` | `TypeError` (+ `include CpfGen::Error`) | Uso indevido da API | Opção do gerador (`format` / `prefix`) com tipo errado |
| `CpfGen::ValidationError` | `CpfGen::DomainError` | Erro de domínio | `prefix` inelegível (base zerada ou 9 dígitos repetidos) |
| `CpfVal::TypeMismatchError` | `TypeError` (+ `include CpfVal::Error`) | Uso indevido da API | Entrada de CPF não é `String` nem `Array` de strings |

##### `CpfFmt::DomainError`

- **Herança:** `CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — ancestral das folhas de domínio do formatador.
- **Quando é lançado:** Não é lançado diretamente; alvo de rescue para `OutOfRangeError`, `ValidationError` e `InvalidLengthError` re-lançado.
- **Exemplo:** Prefira resgatar uma folha, ou `CpfFmt::DomainError` para todas as falhas de domínio do formatador.
- **Como resgatá-lo:**

```ruby
rescue CpfFmt::DomainError
  # OutOfRangeError, ValidationError, InvalidLengthError (se re-lançado de on_fail)
```

##### `CpfFmt::TypeMismatchError`

- **Herança:** `CpfFmt::TypeMismatchError < TypeError` (inclui `CpfFmt::Error`)
- **Categoria:** Uso indevido da API — tipo errado para entrada de CPF ou opção do formatador.
- **Quando é lançado:** Quando `#format` / `cpf_fmt` recebe entrada que não é `String` / `Array<String>`, uma opção tem tipo errado, ou `on_fail` não retorna `String`.
- **Exemplo:**

```ruby
CpfUtils.new.format(12_345)   # lança CpfFmt::TypeMismatchError
```

- **Como resgatá-lo:**

```ruby
rescue CpfFmt::TypeMismatchError
  # violação de contrato de tipo do formatador

rescue TypeError
  # erros nativos de tipo, incluindo CpfFmt::TypeMismatchError
```

##### `CpfFmt::InvalidArgumentCombinationError`

- **Herança:** `CpfFmt::InvalidArgumentCombinationError < ArgumentError` (inclui `CpfFmt::Error`)
- **Categoria:** Uso indevido da API — `options` e keywords misturados na API do formatador.
- **Quando é lançado:** Por `CpfFmt::CpfFormatter` / `CpfFmt.cpf_fmt` quando uma instância/`Hash` de `options` e qualquer argumento nomeado não-`nil` são passados juntos. (A fachada lança `CpfUtils::InvalidArgumentCombinationError` para o mesmo padrão em `CpfUtils#format`.)
- **Exemplo:**

```ruby
CpfFmt::CpfFormatter.new({ dash_key: '_' }, hidden: true)
# lança CpfFmt::InvalidArgumentCombinationError
```

- **Como resgatá-lo:**

```ruby
rescue CpfFmt::InvalidArgumentCombinationError
  # combinação de assinatura inválida do formatador

rescue ArgumentError
  # erros nativos de argumento, incluindo este
```

##### `CpfFmt::InvalidLengthError` (entregue via callback)

- **Herança:** `CpfFmt::InvalidLengthError < CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — comprimento sanitizado do CPF não é exatamente 11.
- **Quando é lançado:** **Não é lançado** por `#format` / `cpf_fmt`; é construído e passado como segundo argumento de `on_fail`.
- **Exemplo:**

```ruby
custom_fail = ->(value, error) {
  error   # => #<CpfFmt::InvalidLengthError ...>
  "CPF inválido: #{value}"
}

CpfUtils.new.format('123', on_fail: custom_fail)   # => "CPF inválido: 123"
CpfUtils.new.format('123')                         # => "" (on_fail padrão)
```

- **Como resgatá-lo:** Trate dentro de `on_fail` (típico), ou faça rescue se re-lançar:

```ruby
rescue CpfFmt::InvalidLengthError
  # esta violação exata de comprimento

rescue CpfFmt::DomainError
  # falhas de domínio com raiz em RangeError de cpf-fmt
```

##### `CpfFmt::OutOfRangeError`

- **Herança:** `CpfFmt::OutOfRangeError < CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — `hidden_start` / `hidden_end` fora de `0`–`10`.
- **Quando é lançado:** Ao construir ou aplicar opções do formatador com índice de ocultação fora da faixa.
- **Exemplo:**

```ruby
CpfUtils.new.format('12345678909', hidden_start: -1)   # lança CpfFmt::OutOfRangeError
```

- **Como resgatá-lo:**

```ruby
rescue CpfFmt::OutOfRangeError
  # esta violação exata de faixa

rescue CpfFmt::DomainError
  # falhas de domínio com raiz em RangeError de cpf-fmt
```

##### `CpfFmt::ValidationError`

- **Herança:** `CpfFmt::ValidationError < CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — opção de chave com caractere proibido.
- **Quando é lançado:** Quando `hidden_key`, `dot_key` ou `dash_key` contém um caractere proibido.
- **Exemplo:**

```ruby
CpfUtils.new(formatter: { dot_key: 'å' })   # lança CpfFmt::ValidationError
```

- **Como resgatá-lo:**

```ruby
rescue CpfFmt::ValidationError
  # esta falha exata de validação de domínio

rescue CpfFmt::DomainError
  # falhas de domínio com raiz em RangeError de cpf-fmt
```

##### `CpfGen::DomainError`

- **Herança:** `CpfGen::DomainError < RangeError` (inclui `CpfGen::Error`)
- **Categoria:** Erro de domínio — ancestral das folhas de domínio do gerador.
- **Quando é lançado:** Não é lançado diretamente; alvo de rescue para `CpfGen::ValidationError`.
- **Exemplo:** Prefira `rescue CpfGen::ValidationError` ou `CpfGen::DomainError`.
- **Como resgatá-lo:**

```ruby
rescue CpfGen::DomainError
  # ValidationError e outras subclasses de DomainError de cpf-gen
```

##### `CpfGen::TypeMismatchError`

- **Herança:** `CpfGen::TypeMismatchError < TypeError` (inclui `CpfGen::Error`)
- **Categoria:** Uso indevido da API — tipo errado para opção do gerador.
- **Quando é lançado:** Quando `format` ou `prefix` tem o tipo de runtime errado.
- **Exemplo:**

```ruby
CpfUtils.new.generate(prefix: 123)   # lança CpfGen::TypeMismatchError
```

- **Como resgatá-lo:**

```ruby
rescue CpfGen::TypeMismatchError
  # violação de contrato de tipo do gerador

rescue TypeError
  # erros nativos de tipo, incluindo CpfGen::TypeMismatchError
```

##### `CpfGen::InvalidArgumentCombinationError`

- **Herança:** `CpfGen::InvalidArgumentCombinationError < ArgumentError` (inclui `CpfGen::Error`)
- **Categoria:** Uso indevido da API — `options` e keywords misturados na API do gerador.
- **Quando é lançado:** Por `CpfGen::CpfGenerator` / `CpfGen.cpf_gen` quando uma instância/`Hash` de `options` e qualquer argumento nomeado não-`nil` são passados juntos. (A fachada lança `CpfUtils::InvalidArgumentCombinationError` para o mesmo padrão em `CpfUtils#generate`.)
- **Exemplo:**

```ruby
CpfGen::CpfGenerator.new({ format: true }, prefix: '123')
# lança CpfGen::InvalidArgumentCombinationError
```

- **Como resgatá-lo:**

```ruby
rescue CpfGen::InvalidArgumentCombinationError
  # combinação de assinatura inválida do gerador

rescue ArgumentError
  # erros nativos de argumento, incluindo este
```

##### `CpfGen::ValidationError`

- **Herança:** `CpfGen::ValidationError < CpfGen::DomainError < RangeError` (inclui `CpfGen::Error`)
- **Categoria:** Erro de domínio — `prefix` inelegível.
- **Quando é lançado:** Quando `prefix` é base zerada (`'000000000'`) ou 9 dígitos repetidos (ex.: `'999999999'`).
- **Exemplo:**

```ruby
CpfUtils.new.generate(prefix: '000000000')   # lança CpfGen::ValidationError
```

- **Como resgatá-lo:**

```ruby
rescue CpfGen::ValidationError
  # esta falha exata de validação de domínio

rescue CpfGen::DomainError
  # falhas de domínio com raiz em RangeError de cpf-gen
```

##### `CpfVal::TypeMismatchError`

- **Herança:** `CpfVal::TypeMismatchError < TypeError` (inclui `CpfVal::Error`)
- **Categoria:** Uso indevido da API — tipo errado para entrada de CPF.
- **Quando é lançado:** Quando `#is_valid` / `cpf_val` recebe valor que não é `String` nem `Array` de strings (incluindo elemento não-string no array). **Dados** de CPF inválidos retornam `false` e não lançam.
- **Exemplo:**

```ruby
CpfUtils.new.is_valid(12_345_678_909)   # lança CpfVal::TypeMismatchError
CpfUtils.new.is_valid('12345678900')    # => false (dados inválidos, sem raise)
```

- **Como resgatá-lo:**

```ruby
rescue CpfVal::TypeMismatchError
  # violação de contrato de tipo do validador

rescue TypeError
  # erros nativos de tipo, incluindo CpfVal::TypeMismatchError
```

### Pacotes incluídos

| Pacote | Principais recursos | README |
|--------|---------------------|--------|
| [`cpf-fmt`](https://rubygems.org/gems/cpf-fmt) | `CpfFmt::CpfFormatter`, `CpfFmt::CpfFormatterOptions`, `CpfFmt.cpf_fmt` | [docs](../cpf-fmt/README.pt.md) |
| [`cpf-gen`](https://rubygems.org/gems/cpf-gen) | `CpfGen::CpfGenerator`, `CpfGen::CpfGeneratorOptions`, `CpfGen.cpf_gen` | [docs](../cpf-gen/README.pt.md) |
| [`cpf-val`](https://rubygems.org/gems/cpf-val) | `CpfVal::CpfValidator`, `CpfVal.cpf_val` | [docs](../cpf-val/README.pt.md) |

Todos os pacotes acima são instalados como dependências de **`cpf-utilities`**. Para tabelas de opções exaustivas, listas de exceções e comportamento em casos extremos, consulte o README de cada pacote.

## Contribuição e suporte

Contribuições são bem-vindas! Consulte as [Diretrizes de contribuição](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md). Se o projeto for útil para você, considere:

- ⭐ Dar uma estrela no repositório
- 🤝 Contribuir com código
- 💡 [Sugerir novas funcionalidades](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reportar bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## Licença

Este projeto está sob a licença MIT — veja o arquivo [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE).

## Changelog

Veja o [CHANGELOG](./CHANGELOG.md) para alterações e histórico de versões.

---

Feito com ❤️ por [Lacus Solutions](https://github.com/LacusSolutions)
