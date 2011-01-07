%w[sinatra haml mechanize].each { |lib| require lib }

get '/' do
  haml :index
end

get '/menu' do
  haml :menu
end

get '/url/*' do
  raise 'Hi!' unless URI.parse(params[:splat][0]).host.match(/apple.com$/)
  agent = WWW::Mechanize.new
  agent.pre_connect_hooks << lambda do |p|
    p[:request]['X-Apple-Store-Front'] = '143441-1,13'
    p[:request]['Accept'] = 'application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'
    p[:request]['X-Apple-Partner'] = 'origin.0'
    p[:request]['Accept-Language'] = 'en-us'
    p[:request]['X-Apple-Connection-Type'] = 'WiFi'
    p[:request]['User-Agent'] = 'MacAppStore/1.0 (Macintosh; U; Intel Mac OS X 10.6.6; en) AppleWebKit/533.18.1'
    p[:request]['Accept-Encoding'] = 'gzip, deflate'
    p[:request]['Connection'] = 'keep-alive'
    p[:request]['Host'] = 'itunes.apple.com'
  end

  page = agent.get(params[:splat][0]).parser

  page.css('a').each do |link|
    link['href'] = "/url/#{CGI.escape(link['href'])}"
  end

  page.to_s
end

get '/search' do
  redirect "/url/#{CGI.escape('http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?q=')}#{params[:q]}"
end

__END__

@@ index
!!!
%html
  %frameset{ :rows => '40,*', :border => 1, :bordercolor => '#51534e', :noresize => 'noresize'}
    %frame{ :src => '/menu', :scrolling => 'no'}
    %frame{ :name => 'main', :src => "/url/#{CGI.escape('http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewGrouping?mt=12&id=29520')}" }

@@ menu
!!!
%html
  %head
    :css
      html {height: 100%;}
      body {height: 100%; line-height: 22px; text-align: center; font-family: 'Lucida Grande', Helvetica, sans-serif; font-size: 11px; background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0, rgb(171,173,168)), color-stop(1, rgb(208,208,208))); background-image: -moz-linear-gradient(center bottom, rgb(171,173,168) 0%, rgb(208,208,208) 100%)}
      form {float: right}
      #egbert {float: left}
      a {color: #000; text-decoration: none; padding-right: 20px}
      a:hover, a:active {color: #008ce2;}
  %body
    %a{:target => 'main', :href => "/url/#{CGI.escape('http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewGrouping?mt=12&id=29520')}"} Featured
    %a{:target => 'main', :href => "/url/#{CGI.escape('http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTopSummary?s=143441')}"} Top Charts
    %a{:target => 'main', :href =>"/url/#{CGI.escape('http://itunes.apple.com/us/genre/mac-app-store/id39')}"} Categories
    %form{ :target => 'main', :action =>'/search'}
      %input{:type => 'search', :name => 'q'}
    #egbert
      by 
      %a{ :href => 'http://twitter.com/egbrt'} @egbrt
