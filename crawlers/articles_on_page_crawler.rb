class ArticlesOnPageCrawler
  @queue = :crawler

  def self.perform(page=1)
    new(page)
  end

  def initialize(page=1)
    doc = Nokogiri::HTML(open("http://escoladigital.org.br/pesquisa-avancada/page/#{page}"))

    links = doc.css(".lista-itens-right .entry-meta a").map{|a| a[:href] }
    links.each{|link| Resque.enqueue(ArticleCrawler, link) }
  end
end