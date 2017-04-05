window.App =
  alert: (msg, to) ->
    $(to).before("<div class='alert alert-danger' id='alert-comp'><a class='close' href='#' data-dismiss='alert'>×</a>#{msg}</div>")
  
  notice: (msg, to) ->
    $(to).before("<div class='alert alert-success' id='notice-comp'><a class='close' href='#' data-dismiss='alert'>×</a>#{msg}</div>")
        
  getCode: (el) ->
    $('#alert-comp').remove()
    $('#notice-comp').remove()
    if $(el).data("loading") == '1'
      return false
      
    mobile = $("#user_mobile").val()
    blank_mobile = mobile.replace(/\s+/, "")
    if blank_mobile.length == 0
      App.alert("手机号不能为空", $('#signup_form'))
      return false
    
    # captcha = $("#user_captcha").val()
    # if captcha.length == 0
    #   App.alert("图片验证码不能为空", $('#new_user'))
    #   return false
      
    reg = /^1[3|4|5|8|7][0-9]\d{8}$/
    if not reg.test(mobile)
      App.alert("不正确的手机号", $('#signup_form'))
      return false
      
    $(el).attr("disabled", true)
    $(el).data("loading", '1')
    $(el).text('59秒后重新获取')
    total = 58
    timer = setInterval (->
      if total == 0
        clearInterval(timer)
        $(el).removeAttr("disabled")
        $(el).text("获取验证码")
        $(el).data("loading", '0')
        return
      
      $(el).text((total--) + '秒后重新获取')
    ), 1000
    
    $.ajax
      url:  "http://cloud.deyiwifi.com/api/v1/auth_codes"
      type: "POST"
      data: { mobile: mobile, type: parseInt($("#user_code_type").val()) }
      success: (re) -> 
        # $(el).removeAttr("disabled")
        
        # src = "http://shuiguoshe.com/captcha?i=" + new Date().getTime()
        # $("#captcha").prop('src', src)
        
        if re.code == 0
          App.notice("获取验证码成功", $('#signup_form'))
        else
          clearInterval(timer)
          $(el).data("loading", '0')
          $(el).removeAttr("disabled")
          $(el).text("获取验证码")
          App.alert(re.message, $('#signup_form'))
  
  deleteItem: (el) ->
    # result = confirm("您确定吗？")
    # if !result
    #   return false
    
    loading = $(el).data("loading")
    if loading == '1'
      return false
    
    $(el).data("loading", '1')
    
    id = $(el).data("id")
    type = $(el).data("type")
    $.ajax
      url: "/line_items/#{id}"
      type: "DELETE"
      data: { type: type }
  
  # 完成订单
  completeOrder: (el) ->
    loading = $(el).data("loading")
    if loading == '1'
      return false
    
    $(el).data("loading", '1')
    
    id = $(el).data("id")
    current = $(el).data("current")
    
    $.ajax
      url: "/orders/#{id}/complete"
      type: "PATCH"
      data: { 'current': current }
    
    
  # 取消订单
  cancelOrder: (el) ->
    result = confirm("您确定吗？")
    if !result
      return false
      
    loading = $(el).data("loading")
    if loading == '1'
      return false
    
    $(el).data("loading", '1')
    
    id = $(el).data("id")
    current = $(el).data("current")
    
    $.ajax
      url: "/orders/#{id}/cancel"
      type: "PATCH"
      data: { 'current': current }
    
  # 更新状态
  updateState: (el) ->
    result = confirm("你确定吗?")
    if !result
      return false
    
    state = $(el).data("state")
    
    if state == true
      url = $(el).data("yes-uri")
    else
      url = $(el).data("no-uri")
      
    $.ajax
      url: url
      type: "PATCH"
      success: (re) ->
        if re == "1"
          if state == true
            $(el).text($(el).data("no-text"))
            $(el).data("state", false)
          else 
            $(el).text($(el).data("yes-text"))
            $(el).data("state", true)
        else
          App.alert("抱歉，系统异常", $(el))