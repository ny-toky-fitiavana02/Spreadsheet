class Scrapper
  def get_townhall_email(townhall_url)
     page = Nokogiri::HTML(open(townhall_url))
     hash = {'ville' => "#{page.xpath("/html[1]/body[1]/div[1]/main[1]/section[1]/div[1]/div[1]/div[1]/h1[1]").text}" , 'email' =>  page.xpath("/html[1]/body[1]/div[1]/main[1]/section[2]/div[1]/table[1]/tbody[1]/tr[4]/td[2]").text}
     puts hash
     return hash
  end
  
  def get_townhall_urls(dept_url)
     page = Nokogiri::HTML(open(dept_url))
     arr = []
     i = 0
     i_max = page.css('a.lientxt').count
     until i == i_max
        arr << "https://www.annuaire-des-mairies.com/#{page.css("a.lientxt")[i]['href'][2..-1]}"
        i+=1
     end
     return arr
  end
  
  def initialize(dept)
     @arr=[]
     get_townhall_urls(dept).map{|i| @arr << get_townhall_email(i)}
     return @arr
  end
  
  def save_as_JSON
    File.open("db/emails.json","w") do |f|
      f.write(@arr.map{|i| Hash[i.each_pair.to_a]}.to_json)
    end
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1hL7MdDOl9JqmuSuTkAeN3Q1w2CqCU3fU0aUHQkm3ldg").worksheets[0]
    ws[1, 1] = @arr.first.keys[0]
    ws[1, 2] = @arr.first.keys[1]
    @arr.map.with_index{|hash,index|
      ws[index+2, 1] = hash['ville']
      ws[index+2, 2] = hash['email']
    }
    ws.save
  end  

  def save_as_csv
    CSV.open("db/emails.csv", "wb") do |csv|
      csv << @arr.first.keys
      @arr.each do |hash|
        csv << hash.values
      end
    end
  end
end