class AccountView
    constructor: (@application) ->
        @user = @application.user;
        @password = @application.password;
        @message = "";
        @login_params = { l: @user, p: @password, v:2 };
        @num = 0;

    show : () ->
        self=this;
        $('#titles h1').html('Welcome ' + self.application.user)
        $('#menu').load('/static/html/menu.html')
        $('#content').load("/static/html/user_account.html",
                            -> 
                                self.htmlLoaded(self)
                            )

    htmlLoaded : (self) ->
        self.showUserAccount()

    showUserAccount: ->
        self=this;
        $('#nickname').html(@user)
        $('#password').val(@password)
        $.getJSON('/users/'+self.user+'.json',
                {l:self.user, p:self.password},
                (json) ->
                    self.message = json["status"];
                    $('#message').html(self.message);
                );
        $('#updateButton').click( -> self.update_resource(self) );

    update_resource : (self) ->
        newpassword=$('#password').val();
        $.post(
	        '/accounts/'+self.user+'.json', 
	        {   
                l: self.user,
	            p: self.password,
	            nickname: self.user, 
	            password: newpassword,
	            _method: 'PUT'
            },
	        ->
                self.application.setPassword(newpassword);
                self.password = self.application.password;
                num=self.num;
	            $("#info").prepend('<div id="updated'+num+'">'+self.user+' updated!</div>');
	            setTimeout(
                    -> 
                        $('#updated'+num).remove() 
                    ,
                    1500);
	            self.num++;
	        )
