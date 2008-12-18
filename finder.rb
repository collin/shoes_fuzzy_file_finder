require 'fuzzy_file_finder/lib/fuzzy_file_finder'


Shoes.app :width => 400, :height => 400 do
  @root = ask_open_folder

  ask_for_root = lambda do
    @root = ask_open_folder
    @root    
  end
  
  stack do
    @button = button "Set Search Root", :width => "100%" do
      @root_label.replace ask_for_root[]
    end
  end
  
  stack do
    @root_label = para @root
  end
  
  @query = edit_line :width => "100%" do

    finder = FuzzyFileFinder.new [@root]

    search_for = @query.text
  
    info search_for
  
    matches = finder.find(search_for).sort_by { |m| [-m[:score], m[:path]] }
         
    def color_text text
      matched = /(\(.+?\))/

      match_color = blue
      no_match_color = red

      text.split(matched).map do |part|
        if part.match(/^\(.*\)$/)
          code(part.
            gsub('(', '').
            gsub(')', ''), :stroke => red, :style => "bold")
        else
          code(part, :stroke => blue, :style => "10px")
        end
      end
    end

    @files.clear

    @files.append do
      texts = []

      matches.reject{|match| match[:highlighted_path].match(/~$/) }[0..10].each do |match|
        info match[:highlighted_path]
        para link(color_text(match[:highlighted_path]), :click => proc{
          Thread.new do
            system "gedit #{match[:path]}"
          end
        })
      end
    end
  end

  @files = stack

end
