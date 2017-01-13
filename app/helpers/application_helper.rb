module ApplicationHelper

  def convert_ms_to_time(millisec)
    sec = (millisec/1000).to_s
    Date.strptime(sec, '%s')
  end

end
