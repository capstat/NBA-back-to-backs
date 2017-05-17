library(rvest)
library(stringr)

spread_scraper = function(x){
  ds = str_replace_all(unique(x$Date), "-", "")
  
  base_url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/money-line/?date=%s"
  
  m_lines = data.frame()
  for(d in ds){
    spreads_page = sprintf(base_url, d)
    soup = spreads_page %>%
      read_html() %>%
      html_nodes(xpath="//b|//a") %>%
      html_text()
    just_lines = soup[66:which(soup=="Tell Us")]
    temp = data.frame("Away"=just_lines[seq(1, length(just_lines), 23)],
                      "Home"=just_lines[seq(2, length(just_lines), 23)],
                      "AwayLine"=just_lines[seq(3, length(just_lines), 23)],
                      "HomeLine"=just_lines[seq(4, length(just_lines), 23)])
    temp$AwayLine = as.numeric(str_replace(temp$AwayLine, "\\+", ""))
    temp$HomeLine = as.numeric(str_replace(temp$HomeLine, "\\+", ""))
    temp$Date = d
    m_lines = rbind(m_lines, temp)
  }
  m_lines$Away = as.character(m_lines$Away)
  m_lines$Home = as.character(m_lines$Home)
  return(m_lines)
}
