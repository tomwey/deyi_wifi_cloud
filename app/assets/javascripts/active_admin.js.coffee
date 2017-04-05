#= require active_admin/base
#= require redactor-rails/redactor
#= require redactor-rails/config
#= require redactor-rails/langs/zh_cn
#= require redactor-rails/plugins

$(document).ready ->
  $('#apartment_rent_type').change ->
    val = $('#apartment_rent_type option:selected').text()
    if val == '单间'
      $('#single-room').show()
    else
      $('#single-room').hide()
  
  $('#ad_task_ad_type').change ->
    val = $('#ad_task_ad_type option:selected').val()
    if val == '2'
      $('.ad-link').show()
      $('.ad-contents').hide()
    else
      $('.ad-link').hide()
      $('.ad-contents').show()
  
  $('#channel_support_os').change ->
    val = $('#channel_support_os option:selected').text()
    if val == '1'
      $('#ios-config').show()
      $('#android-config').hide()
    else if val == '2'
      $('#ios-config').hide()
      $('#android-config').show()
    else if val == '3'
      $('#ios-config').show()
      $('#android-config').show()