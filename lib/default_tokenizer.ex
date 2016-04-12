defmodule DefaultTokenizer do
  @stop_words [
    "abaixo", "aca", "acaso",
    "acerca", "acima", "acola", "acula", "ademais", "adentro",
    "adiante", "afinal", "afora", "agora", "agorinha", "ah", "ainda",
    "alem", "algo", "alguem", "algum", "alguma", "algumas", "alguns",
    "ali", "alias", "alo", "ambos", "amiude", "ante", "antes", "ao",
    "aonde", "aos", "apenas", "apesar", "apos", "apud", "aquela",
    "aquelas", "aquele", "aqueles", "aqui", "aquilo", "as", "assim",
    "ate", "atras", "atraves", "basicamente", "bastante", "bastantes",
    "bem", "bis", "bom", "ca", "cada", "cade", "caso", "certa",
    "certamente", "certas", "certeiramente", "certo", "certos", "chez",
    "chi", "comigo", "como", "comumente", "conforme", "confronte",
    "conosco", "conquanto", "consequentemente", "consigo", "consoante",
    "contanto", "contigo", "contra", "contudo", "convosco", "cuja",
    "cujas", "cujo", "cujos", "da", "dai", "dali", "dantes", "daquela",
    "daquelas", "daquele", "daqueles", "daqui", "daquilo", "das", "de",
    "debaixo", "defronte", "dela", "delas", "dele", "deles", "demais",
    "dentre", "dentro", "depois", "desde", "dessa", "dessas", "desse",
    "desses", "desta", "destas", "deste", "destes", "detras",
    "deveras", "diante", "disso", "disto", "diversos", "do", "donde",
    "doravante", "dum", "duma", "dumas", "duns", "durante", "eia",
    "eis", "ela", "elas", "ele", "eles", "em", "embaixo", "embora",
    "enfim", "enquanto", "entanto", "entao", "entre", "entretanto",
    "exceto", "essa", "essas", "esse", "esses", "esta", "estas",
    "este", "estes", "eu", "exatamente", "exceto", "felizmente",
    "frequentemente", "fora", "gracas", "hem", "hum", "ibidem", "idem",
    "in", "inclusive", "inda", "infelizmente", "inicialmente", "isso",
    "ja", "jamais", "la", "las", "largamente", "lha", "lhas", "lhe",
    "lhes", "lho", "lhos", "lo", "los", "logo", "mais", "mal",
    "malgrado", "mas", "me", "mediante", "menos", "meramente", "mesma",
    "mesmas", "mesmo", "mesmos", "meu", "meus", "mim", "minha",
    "minhas", "mui", "muita", "muitas", "muitissimo", "muito",
    "muitos", "mutuamente", "na", "nada", "nadinha", "nalgum",
    "nalguma", "nalgumas", "nalguns", "naquela", "naquelas", "naquele",
    "naqueles", "naquilo", "nao", "nas", "nela", "nelas", "nele",
    "neles", "nem", "nenhum", "nenhuns", "nenhuma", "nenhumas",
    "nessa", "nessas", "nesse", "nesses", "nesta", "nestas", "neste",
    "nestes", "ninguem", "nisso", "nisto", "no", "nos", "nossa",
    "nossas", "nosso", "nossos", "noutra", "noutras", "noutro",
    "noutros", "novamente", "num", "numa", "numas", "nunca",
    "nunquinha", "nuns", "oba", "ola", "onde", "ontem", "opa", "ora",
    "os", "ou", "outra", "outras", "outrem", "outro", "outrora",
    "para", "pela", "pelas", "pelo", "pelos",
    "per", "perante", "pero", "pois", "por", "porem", "porquanto",
    "porque", "portanto", "porventura", "possivelmente",
    "posteriormente", "posto", "pouca", "poucas", "pouco", "poucos",
    "pra", "praquela", "praquelas", "praquele", "praqueles",
    "praquilo", "pras", "praticamente", "prela", "prelas", "prele",
    "preles", "preste", "prestes", "previamente", "primeiramente",
    "principalmente", "priori", "pronto", "propria", "proprias",
    "proprio", "proprios", "proximo", "qual", "qualquer", "quais",
    "quaisquer", "quando", "quanta", "quantas", "quanto", "quantos",
    "quao", "quase", "que", "quem", "quer", "quica", "raramente",
    "realmente", "recentemente", "salvante", "se", "segundo",
    "seguramente", "seja", "sem", "sempre", "senao", "sequer", "seu",
    "seus", "sim", "simplesmente", "sob", "sobre", "sobremaneira",
    "sobremodo", "sobretudo", "somente", "sua", "suas", "tal", "tais",
    "talvez", "tambem", "tampouco", "tanta", "tantas", "tanto",
    "tantos", "tao", "te", "teu", "teus", "tirante", "toda", "todas",
    "todavia", "todo", "todos", "tras", "tu", "tua", "tuas", "tudo",
    "um", "uma", "umas", "uns", "varias", "varios", "vezes", "visto",
    "voce", "voces", "vos", "vossa", "vossas", "vossos", "vulgo"
  ]

  def tokenize(phrase) do
    Tokenizer.tokenize(phrase, @stop_words, [&remove_t_from_gases/1])
  end

  def sanitize(phrase) do
    Tokenizer.sanitize(phrase, @stop_words, [&remove_t_from_gases/1])
  end

  defp remove_t_from_gases(token) do
    String.replace(token, ~r/t$|\ t /, "", global: true)
  end


end
