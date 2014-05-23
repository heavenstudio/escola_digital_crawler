class ArticleCrawler
  include Mongo

  @queue = :crawler

  attr_accessor :attrs, :link, :collection, :doc

  def self.perform(link)
    new(link).parse_and_save
  end

  def initialize(link)
    @link       = link
    @attrs      = {}
  end

  def parse_and_save
    open_db_connection
    return if exists?
    parse
    save
  end

  def open_db_connection
    config      = YAML.load File.read('mongo.yml')
    client      = MongoClient.new config['host'], config['port']
    database    = client[config['database']]
    @collection  = database[config['collection']]
  end

  def exists?
    !@collection.find(original_link: @link).count.zero?
  end

  def parse
    @doc = Nokogiri::HTML(open(@link))
    @attrs[:original_link] =       @link

    # Identifiable by class or id
    @attrs[:title] =               @doc.css('.entry-title').first.text
    @attrs[:summary] =             @doc.css('.entry-content').first.text
    @attrs[:link] =                @doc.css('#link_oda a').first[:href]
    @attrs[:tags] =                @doc.css('#tags_oda a').map(&:text)
    @attrs[:media] =               @doc.css('#tipo_midia a').first.text
    @attrs[:category] =            @doc.css('#tipo_recurso a').first.text
    @attrs[:image_url] =           @doc.css('#imagem_oda_1 img').first[:src] if @doc.at_css('#imagem_oda_1 img')
    @attrs[:related_content] =     @doc.css('#odas_relacionados a').map{|a| a[:href] }.uniq

    # Col 1
    @attrs[:discipline] =          find_attribute('Disciplina:')
    @attrs[:year] =                find_attribute('Ano/Série:')
    @attrs[:multidisciplinarity] = find_attribute_with_multiple_values('Multidisciplinaridade:')
    @attrs[:language] =            find_attribute('Idioma:')
    @attrs[:country] =             find_attribute('País:')

    # Col 2
    @attrs[:main_theme] =          find_main_theme
    @attrs[:sub_themes] =          find_sub_themes
    @attrs[:availabilities] =      find_attribute_with_multiple_values('Disponibilidade:', 2)
    @attrs[:crosscutting_theme] =  find_attribute('Tema Transversal:', 2)
    @attrs[:usage] =               find_attribute('Uso:', 2)
    @attrs[:license] =             find_attribute('Licença de Uso:', 2)
    @attrs[:suggested_by] =        find_attribute('Sugerido por:', 2)
    @attrs[:produced_by] =         find_attribute('Produzido por:', 2)
  end

  def save
    @collection.insert @attrs
  end

  protected
    def find_attribute(label, col=1)
      found_div = find_div(label, col)
      found_div.css('.itens').first.text if node_has_itens?(found_div)
    end

    def find_div(label, col)
      @doc.css("#termos_oda_col_#{col} > div").find{|e| e.css('.chapeu').first.text == label }
    end

    def node_has_itens?(node)
      node && node.at_css('.itens')
    end

    def find_attribute_with_multiple_values(label, col=1)
      found_div = find_div(label, col)
      found_div.css('.itens a').map(&:text) if node_has_itens?(found_div)
    end

    def find_main_theme
      found_div = find_div('Tema  Curricular:', 2)
      found_div.css('.itens a').first.text if node_has_itens?(found_div)
    end

    def find_sub_themes
      found_div = find_div('Tema  Curricular:', 2)
      found_div.css('.itens a').map{|a| a.text.gsub(/\A[\s\u00A0]*-[\s\u00A0]*/,'') }.tap(&:shift) if node_has_itens?(found_div)
    end
end