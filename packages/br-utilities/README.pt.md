![br-utilities para Ruby](https://br-utils.vercel.app/img/cover_br-utils.jpg)

> 🚀 **Suporte total ao [novo formato alfanumérico de CNPJ](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Access documentation in English](./README.md)

Kit em Ruby para as principais operações com dados brasileiros: CPF (Cadastro de Pessoa Física) e CNPJ (Cadastro Nacional da Pessoa Jurídica). Envolve [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) e [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) em uma única classe fachada (`BrUtils`).

## Suporte a Ruby

| ![Ruby 3.1](https://img.shields.io/badge/Ruby-3.1-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) | ![Ruby 4.0](https://img.shields.io/badge/Ruby-4.0-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |

Requer Ruby **≥ 3.1** (veja `required_ruby_version` no gemspec).

## Recursos

- ✅ **API unificada de alto nível**: Helpers de classe `BrUtils.cpf` / `.cnpj` alias de `BrUtils::DEFAULT`; cada domínio oferece `format`, `generate` e `is_valid`
- ✅ **Domínios empacotados**: [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) e [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) instalados juntos
- ✅ **CNPJ alfanumérico**: Suporte completo ao novo formato alfanumérico de CNPJ (a partir de 2026)
- ✅ **Instância reutilizável**: Classe `BrUtils` com configurações padrão opcionais de CPF e CNPJ (mapeamentos aninhados, kwargs planos de componentes ou instâncias prontas de utils)
- ✅ **Acesso em dois níveis**: Prefira atalhos de classes principais na raiz da fachada (`BrUtils::CpfFormatter`, `BrUtils::CnpjValidator`, …); Options, helpers e erros ficam nos módulos aninhados (`BrUtils::CpfFmt`, `BrUtils::CnpjUtils`, …). Os irmãos na raiz (`CpfUtils`, `CnpjUtils`, `CpfFmt`, …) continuam funcionando
- ✅ **Sobrescritas por chamada**: Configure padrões na fachada / utils de domínio; sobrescreva opções em uma única chamada de `format` / `generate` / `is_valid`
- ✅ **Tratamento de erros**: Erros de domínio propagam inalterados dos pacotes incluídos; esta gem define `BrUtils::TypeMismatchError` e `BrUtils::InvalidArgumentCombinationError` para uso indevido da API

## Instalação

Instale a gem diretamente:

```bash
gem install br-utilities
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'br-utilities'
```

Isso instala **`br-utilities`** junto com [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) e [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) (que por sua vez trazem os pacotes componentes de CPF e CNPJ). Você **não** precisa de `gem install` / linhas `gem` separados para os pacotes de domínio ao usar **`br-utilities`**.

## Require

```ruby
require 'br-utilities'
```

## Início rápido

Prefira os helpers de classe do agregador (`BrUtils.cpf` / `BrUtils.cnpj`) para chamadas pontuais — eles encaminham para `BrUtils::DEFAULT`:

```ruby
require 'br-utilities'

cpf = '12345678909'
cnpj = '03603568000195'

# CPF (pessoa física)
BrUtils.cpf.format(cpf)              # => "123.456.789-09"
BrUtils.cpf.generate(format: true)   # => ex.: "478.442.410-55"
BrUtils.cpf.is_valid('123.456.789-09') # => true

# CNPJ (pessoa jurídica)
BrUtils.cnpj.format(cnpj)            # => "03.603.568/0001-95"
BrUtils.cnpj.generate(format: true)  # => ex.: "AB.123.CDE/0001-55"
BrUtils.cnpj.is_valid('98765432000198') # => true
```

**Com agregadores de domínio:**

```ruby
require 'br-utilities'

cpf = '12345678909'
cnpj = '03603568000195'

CpfUtils.format(cpf)      # => "123.456.789-09"
CnpjUtils.format(cnpj)    # => "03.603.568/0001-95"
CpfUtils.is_valid(cpf)    # => true
CnpjUtils.is_valid(cnpj)  # => true
```

**Com helpers funcionais** (módulos irmãos na raiz, carregados por esta gem):

```ruby
require 'br-utilities'

cpf = '12345678909'
cnpj = '03603568000195'

CpfFmt.cpf_fmt(cpf)     # => "123.456.789-09"
CpfVal.cpf_val(cpf)     # => true
CnpjFmt.cnpj_fmt(cnpj)  # => "03.603.568/0001-95"
CnpjVal.cnpj_val(cnpj)  # => true
```

## Utilização

Você pode trabalhar destas formas equivalentes:

1. **`BrUtils.cpf` / `.cnpj`** — helpers de classe para chamadas rápidas (encaminham para `DEFAULT`).
2. **`BrUtils::DEFAULT`** — singleton compartilhado mutável (o mesmo objeto usado pelos helpers de classe; em todo o processo / não isolado por thread).
3. **`BrUtils.new`** — instância configurável com padrões compartilhados entre os domínios CPF e CNPJ.
4. **Agregadores de domínio** — `CpfUtils` / `CnpjUtils` (ou `BrUtils::CpfUtils` / `BrUtils::CnpjUtils`) diretamente.
5. **Classes principais sob `BrUtils`** — `BrUtils::CpfFormatter`, `BrUtils::CnpjGenerator` e atalhos relacionados.
6. **Módulos aninhados do pacote** — Options, helpers, erros e tipos via `BrUtils::CpfFmt` / `CpfGen` / `CpfVal` / `CnpjFmt` / `CnpjGen` / `CnpjVal` / `CpfUtils` / `CnpjUtils`.
7. **Módulos irmãos na raiz** (ainda suportados) — `CpfFmt`, `CnpjUtils` e demais inalterados.

Todas as abordagens expõem as mesmas opções e comportamento dentro de cada domínio. Para tabelas de opções exaustivas e detalhes específicos de cada componente, consulte o README de cada [pacote incluído](#pacotes-incluídos).

### Helpers de classe (`BrUtils.cpf` / `.cnpj`)

Esses métodos de classe retornam as mesmas instâncias de utils de domínio que `BrUtils::DEFAULT`. Prefira-os para chamadas pontuais:

```ruby
BrUtils.cpf.format('12345678909')
BrUtils.cpf.generate(format: true)
BrUtils.cpf.is_valid('12345678909')

BrUtils.cnpj.format('03603568000195')
BrUtils.cnpj.generate(type: 'numeric')
BrUtils.cnpj.is_valid('98765432000198')
```

### `BrUtils::DEFAULT` (instância padrão)

`BrUtils::DEFAULT` é o singleton pré-construído e **mutável** por trás dos helpers de classe (paridade com a exportação padrão do JS / `br_utils` do Python). Sua configuração é **em todo o processo e compartilhada entre threads**: mutá-lo (ex.: `DEFAULT.cpf = …`) afeta chamadas subsequentes de `BrUtils.cpf` / `.cnpj` para todos os callers no processo. Prefira `BrUtils.new` ou opções por chamada para trabalho concorrente ou isolado; instâncias customizadas permanecem independentes de `DEFAULT`:

```ruby
BrUtils::DEFAULT.cpf = CpfUtils.new(formatter: { dash_key: '|' })
BrUtils.cpf.format('12345678909')   # => "123.456.789|09"

custom = BrUtils.new
custom.cpf.format('12345678909')    # => "123.456.789-09" (não afetado)
```

### `BrUtils` (classe)

Para utils de CPF ou CNPJ padrão customizados, crie sua própria instância:

```ruby
require 'br-utilities'

utils = BrUtils.new(
  cpf: {
    formatter: { hidden: true, hidden_key: '#' },
    generator: { format: true }
  },
  cnpj: {
    formatter: { hidden: true },
    generator: { type: 'numeric', format: true },
    validator: { type: 'numeric' }
  }
)

utils.cpf.format('12345678909')        # => "123.###.###-##"
utils.cpf.generate                     # => ex.: "005.265.352-88"
utils.cnpj.format('03603568000195')    # => "03.603.***/****-**"
utils.cnpj.generate                    # => ex.: "73.008.535/0005-06"

# Acessar ou substituir instâncias internas de domínio
utils.cpf    # => CpfUtils
utils.cnpj   # => CnpjUtils
```

- **`BrUtils.new(settings = nil, **keywords)`**: Configurações opcionais. Passe um `Hash` de settings com chaves `:cpf` e/ou `:cnpj`, **ou** as mesmas chaves (mais kwargs planos de componentes) como argumentos nomeados — não ambos (passar ambos lança `BrUtils::InvalidArgumentCombinationError`).
  - **`:cpf` / `:cnpj`**: Uma instância pronta de `CpfUtils` / `CnpjUtils` **ou** um `Hash` de configuração repassado ao construtor do utils correspondente. Dentro desse `Hash`, cada chave de recurso (`:formatter`, `:generator` e `:validator` para CNPJ) aceita um objeto de opções ou um mapeamento de valores de opção.
  - **`:cpf_formatter`**, **`:cpf_generator`**, **`:cnpj_formatter`**, **`:cnpj_generator`**, **`:cnpj_validator`**: Argumentos planos de conveniência quando apenas componentes individuais precisam de customização. São ignorados quando o argumento `:cpf` ou `:cnpj` correspondente é fornecido.
- **`#cpf`**, **`#cnpj`**: Acessores (getters e setters) das instâncias de utils de domínio. Os setters aceitam uma instância de utils, um `Hash` de configuração ou `nil` para voltar aos padrões (substitui a instância inteira; não faz merge).

Opções planas no construtor (alternativa aos mapeamentos aninhados `:cpf` / `:cnpj`):

```ruby
require 'br-utilities'

utils = BrUtils.new(
  cpf_formatter: CpfFmt::CpfFormatterOptions.new(hidden: true, hidden_key: '#'),
  cpf_generator: CpfGen::CpfGeneratorOptions.new(format: true),
  cnpj_formatter: CnpjFmt::CnpjFormatterOptions.new(hidden: true, hidden_key: '#'),
  cnpj_generator: CnpjGen::CnpjGeneratorOptions.new(format: true, type: 'numeric'),
  cnpj_validator: CnpjVal::CnpjValidatorOptions.new(type: 'numeric')
)
```

Passar um `Hash` de settings posicional junto com qualquer palavra-chave lança:

```ruby
BrUtils.new({ cpf: {} }, cnpj: CnpjUtils.new)
# lança BrUtils::InvalidArgumentCombinationError
```

### Padrões da instância e sobrescritas por chamada

```ruby
require 'br-utilities'

utils = BrUtils.new(
  cpf: {
    formatter: { hidden: true, hidden_key: '#' },
    generator: { format: true }
  },
  cnpj: {
    formatter: { hidden: true, hidden_key: '#' },
    generator: { format: true },
    validator: { type: 'numeric' }
  }
)

cpf = '12345678909'
cnpj = '03603568000195'

utils.cpf.format(cpf)                  # => "123.###.###-##"
utils.cpf.format(cpf, hidden: false)   # só nesta chamada: sem máscara
utils.cpf.generate(format: false)      # só nesta chamada: saída compacta

utils.cnpj.format(cnpj)                  # => "03.603.###/####-##"
utils.cnpj.format(cnpj, hidden: false)   # só nesta chamada: sem máscara
utils.cnpj.is_valid('1QB5UKALPYFP59')    # => false (validador da instância é só numérico)
utils.cnpj.is_valid(                     # => true nesta chamada
  '1QB5UKALPYFP59',
  type: 'alphanumeric'
)
```

Passar uma instância de `CnpjFmt::CnpjFormatterOptions`, `CnpjGen::CnpjGeneratorOptions` ou `CnpjVal::CnpjValidatorOptions` ao construtor de `BrUtils` armazena esse objeto por referência — mutá-lo depois afeta chamadas subsequentes sem sobrescrita por chamada.

Para alterar uma única opção aninhada sem substituir o utils de domínio inteiro, mute via os acessores de domínio (ex.: `utils.cpf.formatter.options.hidden = true`).

### Operações de CPF

Os métodos de CPF são acessados via `BrUtils.cpf`, `utils.cpf`, `CpfUtils` ou os helpers `CpfFmt` / `CpfGen` / `CpfVal`. O CPF usa a API de [`cpf-utilities`](../cpf-utilities/README.pt.md).

#### Formatação (`#format` / `CpfFmt.cpf_fmt`)

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | Se `true`, mascara dígitos entre `hidden_start` e `hidden_end` com `hidden_key` |
| `hidden_key` | `String` | `'*'` | Caractere(s) usados para substituir dígitos mascarados |
| `hidden_start` | `Integer` | `3` | Índice inicial (0–10, inclusivo) do intervalo a ocultar |
| `hidden_end` | `Integer` | `10` | Índice final (0–10, inclusivo) do intervalo a ocultar |
| `dot_key` | `String` | `'.'` | Delimitador de ponto (ex.: em `123.456.789`) |
| `dash_key` | `String` | `'-'` | Delimitador de hífen (ex.: antes dos dígitos verificadores `…-09`) |
| `escape` | `Boolean` | `false` | Se `true`, escapa caracteres especiais HTML no resultado |
| `encode` | `Boolean` | `false` | Se `true`, codifica o resultado para URL (similar ao `encodeURIComponent` do JavaScript) |
| `on_fail` | `Proc` / invocável | retorna `''` | Callback quando o tamanho da entrada sanitizada ≠ 11; o retorno é usado como resultado |

O **`on_fail`** padrão retorna uma string vazia. Comprimento inválido **não** lança exceção em `#format`.

```ruby
require 'br-utilities'

cpf = '12345678909'

BrUtils.cpf.format(cpf)                              # => "123.456.789-09"
BrUtils.cpf.format(cpf, hidden: true, hidden_key: '#') # => "123.###.###-##"
BrUtils.cpf.format(cpf, dot_key: '', dash_key: '_')  # => "123456789_09"

CpfFmt.cpf_fmt(cpf, hidden: true)                    # => "123.***.***-**"
```

#### Geração (`#generate` / `CpfGen.cpf_gen`)

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | Se `true`, retorna o CPF gerado no formato padrão (`000.000.000-00`) |
| `prefix` | `String` | `''` | String parcial inicial (0–9 dígitos). Não dígitos são removidos; caracteres faltantes são gerados e os dígitos verificadores calculados. Prefixos com mais de 9 dígitos são truncados silenciosamente. |

Regras de prefixo: a base (primeiros 9 dígitos) não pode ser toda zeros; 9 dígitos repetidos (ex.: `999999999`) não são permitidos.

```ruby
require 'br-utilities'

BrUtils.cpf.generate                       # => ex.: "11508890048"
BrUtils.cpf.generate(format: true)         # => ex.: "661.134.831-00"
BrUtils.cpf.generate(prefix: '123456789')  # => "12345678909"
CpfGen.cpf_gen(prefix: '123456789', format: true) # => "123.456.789-09"
```

#### Validação (`#is_valid` / `CpfVal.cpf_val`)

Aceita CPF formatado ou não (ou um `Array` de strings). Retorna **`true`** ou **`false`** sem lançar exceção para CPF inválido. Não há opções de validador.

```ruby
require 'br-utilities'

BrUtils.cpf.is_valid('12345678909')      # => true
BrUtils.cpf.is_valid('123.456.789-09')   # => true
BrUtils.cpf.is_valid('12345678900')      # => false
CpfVal.cpf_val('12345678909')            # => true
```

### Operações de CNPJ

Os métodos de CNPJ são acessados via `BrUtils.cnpj`, `utils.cnpj`, `CnpjUtils` ou os helpers `CnpjFmt` / `CnpjGen` / `CnpjVal`. O CNPJ usa a API de [`cnpj-utilities`](../cnpj-utilities/README.pt.md).

#### Formatação (`#format` / `CnpjFmt.cnpj_fmt`)

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | Se `true`, mascara caracteres entre `hidden_start` e `hidden_end` com `hidden_key` |
| `hidden_key` | `String` | `'*'` | Caractere(s) usados para substituir caracteres mascarados |
| `hidden_start` | `Integer` | `5` | Índice inicial (0–13, inclusivo) do intervalo a ocultar |
| `hidden_end` | `Integer` | `13` | Índice final (0–13, inclusivo) do intervalo a ocultar |
| `dot_key` | `String` | `'.'` | Delimitador de ponto (ex.: em `12.345.678`) |
| `slash_key` | `String` | `'/'` | Delimitador de barra (ex.: antes da filial `…/0001-90`) |
| `dash_key` | `String` | `'-'` | Delimitador de hífen (ex.: antes dos dígitos verificadores `…-90`) |
| `escape` | `Boolean` | `false` | Se `true`, escapa caracteres especiais HTML no resultado |
| `encode` | `Boolean` | `false` | Se `true`, codifica o resultado para URL (similar ao `encodeURIComponent` do JavaScript) |
| `on_fail` | `Proc` / invocável | retorna `''` | Callback quando o tamanho da entrada sanitizada ≠ 14; o retorno é usado como resultado |

O **`on_fail`** padrão retorna uma string vazia. Tipos de entrada incorretos lançam **`CnpjFmt::TypeMismatchError`**.

```ruby
require 'br-utilities'

cnpj = '03603568000195'

BrUtils.cnpj.format(cnpj)              # => "03.603.568/0001-95"
BrUtils.cnpj.format('12ABC34500DE99')  # => "12.ABC.345/00DE-99"
BrUtils.cnpj.format(                   # => "03.603.###/####-##"
  cnpj,
  hidden: true,
  hidden_key: '#'
)
BrUtils.cnpj.format(                   # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)

CnpjFmt.cnpj_fmt(cnpj)                 # => "03.603.568/0001-95"
```

#### Geração (`#generate` / `CnpjGen.cnpj_gen`)

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | Se `true`, retorna o CNPJ gerado no formato padrão (`00.000.000/0000-00`) |
| `prefix` | `String` | `''` | String parcial inicial (0–12 caracteres alfanuméricos). Caracteres faltantes são gerados e os dígitos verificadores calculados. |
| `type` | `String` | `'alphanumeric'` | Conjunto de caracteres para a parte gerada aleatoriamente: `'numeric'`, `'alphabetic'` ou `'alphanumeric'`. **Os dígitos verificadores são sempre numéricos.** |

Regras de prefixo: o ID base (primeiros 8 caracteres) e o ID da filial (caracteres 9–12) não podem ser todos zeros; 12 dígitos repetidos (ex.: `111111111111`) também não são permitidos.

```ruby
require 'br-utilities'

BrUtils.cnpj.generate               # => ex.: "1GJTR3J3XSSA96"
BrUtils.cnpj.generate(format: true) # => ex.: "V1.J0V.8WE/DVZ7-50"
BrUtils.cnpj.generate(              # => ex.: "12345678855883"
  prefix: '12345678',
  type: 'numeric'
)
CnpjGen.cnpj_gen(type: 'numeric')   # => ex.: "65453043000178"
```

#### Validação (`#is_valid` / `CnpjVal.cnpj_val`)

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `case_sensitive` | `Boolean` | `true` | Se `false`, letras minúsculas são aceitas para CNPJ alfanumérico (a entrada é convertida para maiúsculas antes da validação). |
| `type` | `String` | `'alphanumeric'` | `'numeric'`: apenas dígitos (0–9); `'alphanumeric'`: dígitos e letras (0–9, A–Z). |

```ruby
require 'br-utilities'

BrUtils.cnpj.is_valid('98765432000198')   # => true
BrUtils.cnpj.is_valid('98765432000199')   # => false
BrUtils.cnpj.is_valid('1QB5UKALPYFP59')   # => true
BrUtils.cnpj.is_valid('1QB5UKALpyfp59')   # => false
BrUtils.cnpj.is_valid(                     # => true
  '1QB5UKALpyfp59',
  case_sensitive: false
)
BrUtils.cnpj.is_valid(                     # => false
  '1QB5UKALPYFP59',
  type: 'numeric'
)

CnpjVal.cnpj_val('98765432000198')                         # => true
CnpjVal.cnpj_val('1QB5UKALpyfp59', case_sensitive: false)  # => true
CnpjVal.cnpj_val('1QB5UKALPYFP59', type: 'numeric')        # => false
```

CNPJ inválido retorna **`false`** sem lançar exceção. Tipos de entrada incorretos lançam **`CnpjVal::TypeMismatchError`**.

### Agregadores de domínio (isolados)

Use `CpfUtils` ou `CnpjUtils` diretamente quando precisar de apenas um domínio:

```ruby
require 'br-utilities'

cpf_utils = CpfUtils.new(
  formatter: { hidden: true },
  generator: { format: true }
)

cnpj_utils = CnpjUtils.new(
  formatter: { hidden: true },
  generator: { format: true },
  validator: { type: 'numeric' }
)

cpf_utils.format('12345678909')       # => "123.***.***-**"
cnpj_utils.format('03603568000195')   # => "03.603.***/****-**"
```

### Acessando componentes

Cada agregador de domínio expõe seu formatador, gerador e validador internos:

```ruby
require 'br-utilities'

utils = BrUtils.new

utils.cpf.formatter.format('12345678909', hidden: true)  # => "123.***.***-**"
utils.cpf.generator.generate(format: true)               # => ex.: "545.507.690-68"
utils.cpf.validator.is_valid('12345678909')              # => true

utils.cnpj.formatter.format('12ABC34500DE99')            # => "12.ABC.345/00DE-99"
utils.cnpj.generator.generate(format: true)              # => ex.: "8O.BE5.2KL/UI0Y-06"
utils.cnpj.validator.is_valid('03603568000195')          # => true
```

### Usando classes componentes e módulos aninhados

Caminhos preferidos após `require 'br-utilities'`:

```ruby
require 'br-utilities'

# Classes principais na raiz da fachada
formatter = BrUtils::CpfFormatter.new(hidden: true)
generator = BrUtils::CnpjGenerator.new(type: 'numeric')
validator = BrUtils::CnpjValidator.new

formatter.format('12345678909')   # => "123.***.***-**"

# Options, helpers e erros nos módulos aninhados do pacote
options = BrUtils::CpfFmt::CpfFormatterOptions.new(dash_key: '|')
BrUtils::CpfFmt.cpf_fmt('12345678909')   # => "123.456.789-09"

begin
  BrUtils::CnpjFmt.cnpj_fmt(12_345)
rescue BrUtils::CnpjFmt::TypeMismatchError
  # tipo de entrada incorreto
end
```

Os irmãos na raiz continuam suportados (os mesmos objetos dos nests):

```ruby
CpfFmt.cpf_fmt('12345678909', dash_key: '|')   # => "123.456.789|09"
CpfGen.cpf_gen(format: true)                   # => ex.: "478.442.410-55"
CpfVal.cpf_val('12345678909')                  # => true
CnpjFmt.cnpj_fmt('01ABC234000X56', slash_key: '|') # => "01.ABC.234|000X-56"
CnpjGen.cnpj_gen(type: 'numeric')              # => ex.: "65453043000178"
CnpjVal.cnpj_val('9JN7MGLJZXIO50')             # => true
```

Consulte [`cpf-utilities`](../cpf-utilities/README.pt.md) e [`cnpj-utilities`](../cnpj-utilities/README.pt.md) para detalhes completos de opções e erros.

### Misturando estilos

Use `BrUtils` onde uma configuração compartilhada ajuda, e componentes ou helpers isolados em outros pontos — são as mesmas classes subjacentes:

```ruby
require 'br-utilities'

utils = BrUtils.new(cnpj: { validator: { type: 'numeric' } })

# Via fachada
utils.cpf.format('12345678909')   # => "123.456.789-09"

# Via componente retornado pela fachada
utils.cnpj.formatter.format('12ABC34500DE99')   # => "12.ABC.345/00DE-99"

# Via instância de componente separada
BrUtils::CnpjFormatter.new.format('03603568000195')   # => "03.603.568/0001-95"

# Via helpers funcionais
CpfFmt.cpf_fmt('12345678909')           # => "123.456.789-09"
CnpjVal.cnpj_val('98.765.432/0001-98')  # => true
```

## API

### Exportações

Após `require 'br-utilities'`:

- **`BrUtils`**: Classe fachada para criar uma instância com configurações opcionais dos utils de CPF e CNPJ.
- **`BrUtils.cpf` / `.cnpj`**: Helpers de classe que encaminham para os acessores de domínio de `BrUtils::DEFAULT`.
- **`BrUtils::DEFAULT`**: Instância pré-construída e mutável de `BrUtils` (o mesmo objeto usado pelos helpers de classe). Em todo o processo / compartilhada entre threads — prefira `BrUtils.new` ou opções por chamada sob concorrência.
- **`BrUtils::VERSION`**: String da versão da gem.
- **Atalhos de classes principais**: `BrUtils::CpfFormatter`, `BrUtils::CpfFormatterOptions`, `BrUtils::CpfGenerator`, `BrUtils::CpfGeneratorOptions`, `BrUtils::CpfValidator`, `BrUtils::CnpjFormatter`, `BrUtils::CnpjFormatterOptions`, `BrUtils::CnpjGenerator`, `BrUtils::CnpjGeneratorOptions`, `BrUtils::CnpjValidator`, `BrUtils::CnpjValidatorOptions` (os mesmos objetos das classes irmãs). Atalhos de marcadores de erro: `BrUtils::CpfFormatterError`, `BrUtils::CpfGeneratorError`, `BrUtils::CpfValidatorError`, `BrUtils::CnpjFormatterError`, `BrUtils::CnpjGeneratorError`, `BrUtils::CnpjValidatorError`.
- **Módulos aninhados do pacote**: `BrUtils::CpfUtils`, `BrUtils::CnpjUtils`, `BrUtils::CpfFmt`, `BrUtils::CpfGen`, `BrUtils::CpfVal`, `BrUtils::CnpjFmt`, `BrUtils::CnpjGen`, `BrUtils::CnpjVal` — superfície completa dos irmãos (Options, helpers, erros, tipos).
- **Módulos irmãos na raiz** (ainda suportados): `CpfUtils`, `CnpjUtils`, `CpfFmt`, `CpfGen`, `CpfVal`, `CnpjFmt`, `CnpjGen`, `CnpjVal` — os mesmos objetos dos nests.

### Erros e exceções

`BrUtils` define apenas erros de uso indevido da API para as regras de argumentos desta gem. Erros de domínio são lançados pelos pacotes incluídos e propagam inalterados.

#### Definidos por `br-utilities`

Os erros definidos por esta gem são **apenas uso indevido da API** (tipo errado ou combinação inválida de argumentos). Todo erro customizado inclui o módulo marcador `BrUtils::Error`. Esta gem **não** define `BrUtils::DomainError` nem folhas de domínio — falhas de domínio vêm apenas dos [pacotes incluídos](#propagados-dos-pacotes-incluídos) e mantêm os namespaces desses pacotes (`CpfFmt::…`, `CnpjGen::…`, …).

`rescue BrUtils::Error` captura **apenas** erros que esta gem lança. **Não** captura erros de componentes que propagam inalterados.

##### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|-------|---------------|----------|-------------------|
| `BrUtils::InvalidArgumentCombinationError` | `BrUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (+ `include BrUtils::Error`) | Uso indevido da API | `Hash` de settings não-`nil` passado junto com qualquer argumento nomeado não-`nil` |
| `BrUtils::TypeMismatchError` | `BrUtils::TypeMismatchError < TypeError < StandardError` (+ `include BrUtils::Error`) | Uso indevido da API | Argumento `settings` não-`nil` em `BrUtils.new` não é um `Hash` |

##### `BrUtils::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro customizado que esta gem lança via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de rescue) — não é um modo de falha por si só.
- **Quando é lançado:** Nunca lançado diretamente; incluído por todo erro customizado que esta gem lança.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue BrUtils::Error
  # TypeMismatchError, InvalidArgumentCombinationError apenas desta gem
  # (não CpfFmt::*, CnpjGen::* ou outros erros dos pacotes incluídos)
```

##### `BrUtils::TypeMismatchError`

- **Herança:** `BrUtils::TypeMismatchError < TypeError < StandardError` (inclui `BrUtils::Error`)
- **Categoria:** Uso indevido da API — o caller passou um valor do tipo errado.
- **Quando é lançado:** Quando `BrUtils.new` recebe um argumento `settings` não-`nil` que não é um `Hash`.
- **Exemplo:**

```ruby
BrUtils.new('not-a-hash')   # lança BrUtils::TypeMismatchError
BrUtils.new(false)          # lança BrUtils::TypeMismatchError (false é não-nil)
```

- **Como resgatar:**

```ruby
rescue BrUtils::TypeMismatchError
  # violação de contrato de tipo desta gem

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta gem
```

##### `BrUtils::InvalidArgumentCombinationError`

- **Herança:** `BrUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (inclui `BrUtils::Error`)
- **Categoria:** Uso indevido da API — o caller misturou padrões de argumentos mutuamente exclusivos.
- **Quando é lançado:** Quando `BrUtils.new` recebe um `Hash` de settings não-`nil` e qualquer argumento nomeado não-`nil` (`cpf:`, `cnpj:`, `cpf_formatter:`, …) ao mesmo tempo.
- **Exemplo:**

```ruby
BrUtils.new({ cpf: { formatter: { hidden: true } } }, cnpj: { formatter: { hidden: true } })
# lança BrUtils::InvalidArgumentCombinationError
```

- **Como resgatar:**

```ruby
rescue BrUtils::InvalidArgumentCombinationError
  # combinação inválida de assinatura desta gem

rescue ArgumentError
  # erros nativos de argumento, incluindo InvalidArgumentCombinationError desta gem
```

##### Granularidade de rescue

Cada nível é mostrado como seu próprio exemplo isolado (não os una em uma única escada de `rescue` — um handler nativo amplo tornaria cláusulas mais estreitas inalcançáveis).

```ruby
require 'br-utilities'

# 1) Classe nativa única — captura erros de uso indevido desse tipo,
#    incluindo os não-biblioteca já tratados em outro ponto do código do consumidor.
begin
  BrUtils.new('not-a-hash')
rescue TypeError
  # BrUtils::TypeMismatchError e qualquer outro TypeError (biblioteca ou não)
end

begin
  BrUtils.new({ cpf: {} }, cnpj: CnpjUtils.new)
rescue ArgumentError
  # BrUtils::InvalidArgumentCombinationError e qualquer outro ArgumentError (biblioteca ou não)
end
```

```ruby
require 'br-utilities'

# 2) BrUtils::DomainError — não aplicável: esta gem não define DomainError
#    (nem folhas de domínio). Falhas de domínio vêm apenas dos pacotes incluídos.
# begin
#   BrUtils.new(cpf: { formatter: { hidden_start: -1 } })
# rescue BrUtils::DomainError  # NameError — constante não definida
# end
```

```ruby
require 'br-utilities'

# 3) BrUtils::Error — captura tudo que esta gem lança, independentemente da ancestralidade nativa.
#    Não captura CpfFmt::*, CnpjGen::* ou outros erros dos pacotes incluídos.
begin
  BrUtils.new('not-a-hash')
rescue BrUtils::Error
  # todo erro customizado que inclui BrUtils::Error
end
```

```ruby
require 'br-utilities'

# 4) Classe folha específica — captura apenas aquele modo de falha exato.
begin
  BrUtils.new('not-a-hash')
rescue BrUtils::TypeMismatchError
  # apenas BrUtils::TypeMismatchError
end
```

#### Propagados dos pacotes incluídos

`BrUtils` não redefine tipos de exceção de domínio. Construção, setters e chamadas de métodos de domínio lançam os mesmos erros de [`cpf-utilities`](../cpf-utilities/README.pt.md) e [`cnpj-utilities`](../cnpj-utilities/README.pt.md):

- **Formatação de CPF**: `CpfFmt::TypeMismatchError`, `CpfFmt::OutOfRangeError`, `CpfFmt::ValidationError`, `CpfFmt::InvalidLengthError` (passado a `on_fail`, não lançado por `#format`) e classes relacionadas.
- **Geração de CPF**: `CpfGen::TypeMismatchError`, `CpfGen::ValidationError` e classes relacionadas.
- **Validação de CPF**: `CpfVal::TypeMismatchError` e classes relacionadas.
- **Formatação de CNPJ**: `CnpjFmt::TypeMismatchError`, `CnpjFmt::OutOfRangeError`, `CnpjFmt::ValidationError`, `CnpjFmt::InvalidLengthError` (passado a `on_fail`) e classes relacionadas.
- **Geração de CNPJ**: `CnpjGen::TypeMismatchError`, `CnpjGen::ValidationError` e classes relacionadas.
- **Validação de CNPJ**: `CnpjVal::TypeMismatchError`, `CnpjVal::ValidationError` e classes relacionadas.

Tipos de opção inválidos são tipicamente subclasses de **`TypeError`** (`*::TypeMismatchError`); valores de opção inválidos são erros de domínio sob a hierarquia `DomainError` de cada pacote. Falhas de validação de CPF e CNPJ retornam `false`. Falhas de comprimento na formatação são tratadas por **`on_fail`** (padrão retorna string vazia).

```ruby
require 'br-utilities'

begin
  BrUtils.new.cnpj.format(12_345)
rescue CnpjFmt::TypeMismatchError => e
  puts e.message
end

begin
  BrUtils.new.cnpj.is_valid(12_345_678_000_198)
rescue CnpjVal::TypeMismatchError => e
  puts e.message
end

# on_fail customizado para comprimento inválido
custom_fail = ->(value, _exception) { "Invalid: #{value}" }

BrUtils.cpf.format('short', on_fail: custom_fail)    # => "Invalid: short"
BrUtils.cnpj.format('short', on_fail: custom_fail)   # => "Invalid: short"
BrUtils.cpf.format('short')                          # => "" (on_fail padrão)
```

Para listas exaustivas de exceções e comportamento em casos extremos, consulte o README de cada [pacote incluído](#pacotes-incluídos).

### Pacotes incluídos

| Pacote | Principais recursos | README |
|---------|----------------|--------|
| [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) | `CpfUtils`, `CpfFormatter`, `CpfGenerator`, `CpfValidator`, `CpfFmt.cpf_fmt`, `CpfGen.cpf_gen`, `CpfVal.cpf_val` | [docs](../cpf-utilities/README.pt.md) |
| [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) | `CnpjUtils`, `CnpjFormatter`, `CnpjGenerator`, `CnpjValidator`, `CnpjFmt.cnpj_fmt`, `CnpjGen.cnpj_gen`, `CnpjVal.cnpj_val` | [docs](../cnpj-utilities/README.pt.md) |

Todos os acima são puxados como dependências de **`br-utilities`**. Demos interativas: [CPF](https://cpf-utils.vercel.app/) e [CNPJ](https://cnpj-utils.vercel.app/).

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
