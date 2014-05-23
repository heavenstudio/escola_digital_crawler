class NumberOfPagesCrawler
  @queue = :crawler

  def perform
    new
  end

  def initialize
    doc = Nokogiri::HTML(open('http://escoladigital.org.br/pesquisa-avancada/'))
    number_of_pages = doc.css('.page-numbers').map{|a| a.text.to_i }.max
    puts "#{number_of_pages} páginas encontradas"
    
    1.upto(number_of_pages){|i| Resque.enqueue(ArticlesOnPageCrawler, i) }
  end
end