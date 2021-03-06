<script type="text/javascript" src="{{ @theme('js/jquery.js') }}"></script>
<script type="text/javascript" src="{{ @theme('js/dialog.js') }}"></script>
<script type="text/javascript">
jQuery(document).ready(function () {
	jQuery('#new').click(function() {
		UserList.createUser();
	});
	jQuery('#config').click(function() {
		window.location = '{{ @url('admin/config') }}';
	});
	jQuery('#logout').click(function() {
		window.location = '{{ @url('admin/logout') }}';
	});

	var UserList = {};
	UserList.page = 0;
	UserList.count = 0;
	UserList.perPage = 0;
	
	UserList.headerCell = function (data) {
		var cell = jQuery('<th></th>');
		cell.html(data);
		return cell;
	};
	
	UserList.cell = function (data) {
		var cell = jQuery('<td></td>');
		cell.html(data);
		return cell;
	};
	
	UserList.getUserLevel = function (lvl) {
		var levels = {0:'Activation Required', 1:'Client', 2:'Administrator'};
		return levels[lvl];
	};
	
	UserList.list = function (page) {
		jQuery.get('{{ @url('api/users/') }}'+page, function (result) {
			jQuery('.user-list-panel').children().remove();
			var tbl = jQuery('<table width="100%" class="user-list"></table>');
			
			var row = jQuery('<tr></tr>');
			row.append(UserList.headerCell('Username'));
			row.append(UserList.headerCell('Email Address'));
			row.append(UserList.headerCell('Web Space'));
			row.append(UserList.headerCell('User Level'));
			row.append(UserList.headerCell('Actions'));
			tbl.append(row);
			
			var users = result.users;
			for(var j=0;j<users.length;j++){
				var row = jQuery('<tr></tr>');
				
				var userLink = jQuery('<a href="#"></a>');
				userLink.html(users[j].username);
				userLink.click(function(userId) {
					return function () {
						UserList.showUser(userId);
						return false;
					};
				}(users[j].user_id));
				
				var deleteBtn = jQuery('<button>Remove</button>');
				deleteBtn.click(function(userId) {
					return function () {
						UserList.deleteUser(userId);
						return false;
					};
				}(users[j].user_id));
				
				row.append(UserList.cell(userLink));
				row.append(UserList.cell(users[j].email));
				row.append(UserList.cell(users[j].webspace+' MB'));
				row.append(UserList.cell(UserList.getUserLevel(parseInt(users[j].user_level))));
				row.append(UserList.cell(deleteBtn));
				
				tbl.append(row);
			}
			UserList.page = result.page;
			UserList.count = result.count;
			UserList.perPage = result.perPage;
			
			jQuery('.user-list-panel').append(tbl);
			jQuery('.user-list-panel').append(UserList.getPaginator());
		});
	};
	
	UserList.showUser = function (userId) {
		jQuery.get('{{ @url('api/user/') }}'+userId, function (user) {
			Form.init('user-edit', user.user, ['username', 'email', 'full_name', 'webspace', 'user_level']);
			Dialog.show('user-edit', function (userId) {
				return function (dlg) {
					var data = Form.data('user-edit', ['email', 'full_name', 'webspace', 'user_level']);
					
					jQuery.post('{{ @url('api/user/') }}'+userId+'/edit', data, function (result) {
						if (result.success === true)
						{
							UserList.list(UserList.page);
						}
						else
						{
							alert('ERROR: '+result.message);
						}
					}).fail(function(data) {
						alert('ERROR: Request failed - '+data.responseText);
					});
				};
			}(userId));
		});
	};
	
	UserList.getPaginator = function () {
		var pg = jQuery('<ul class="paginator"></ul>');
		for(var j=0;j<Math.ceil(UserList.count/UserList.perPage);j++){
			var link = jQuery('<li><a href="#">'+(j+1)+'</a></li>');
			link.find('a').click(function(page) {
				return function() {
					UserList.page = page;
					UserList.list();
					return false;
				};
			}(j));
			pg.append(link);
		}
		return pg;
	};
	
	UserList.deleteUser = function (userId) {
		if (confirm('Do you wish to remove this user?'))
		{
			jQuery.post('{{ @url('api/user/') }}'+userId+'/delete', function (result) {
				if (result.user_success === true)
				{
					UserList.list(UserList.page);
				}
				else
				{
					alert('ERROR: '+result.message);
				}
			}).fail(function(data) {
				alert('ERROR: Request failed - '+data.responseText);
			});
		}
	};
	
	UserList.createUser = function () {
		Dialog.show('user-add', function (dlg) {
			var data = Form.data('user-add', ['username', 'password', 'email', 'full_name', 'webspace', 'user_level']);
					
			jQuery.post('{{ @url('api/user/create') }}', data, function (result) {
				if (result.success === true)
				{
					UserList.list(0);
				}
				else
				{
					alert('ERROR: '+result.message);
				}
			}).fail(function(data) {
				alert('ERROR: Request failed - '+data.responseText);
			});
		});
	};
	
	UserList.list(0);
});
</script>

<div class="row">
	<button id="new">Create New User</button>
	<button id="config">Configuration</button>
	<button id="logout">Log Out</button>
</div>
<div class="user-list-panel"></div>
<div class="overlay">
	<div class="dialog" id="user-edit">
		<div class="row">
			<label>Username</label>
			<div class="field" id="username"></div>
		</div>
		<div class="row">
			<label>New Password<br /><small>(leave blank to keep)</small></label>
			<div class="field">
				<input type="password" id="password" autocomplete="off" />
			</div>
		</div>
		<div class="row">
			<label>Email</label>
			<div class="field">
				<input type="text" id="email" />
			</div>
		</div>
		<div class="row">
			<label>Full Name</label>
			<div class="field">
				<input type="text" id="full_name" />
			</div>
		</div>
		<div class="row">
			<label>Web Space</label>
			<div class="field">
				<input type="text" id="webspace" /> MB
			</div>
		</div>
		<div class="row">
			<label>User Level</label>
			<div class="field">
				<select id="user_level">
					<option value="0">Activation Required</option>
					<option value="1">Client</option>
					<option value="2">Administrator</option>
				</select>
			</div>
		</div>
		<div class="row">
			<button class="ok-btn">Save</button>
			<button class="cancel-btn">Cancel</button>
		</div>
	</div>
</div>
<div class="overlay">
	<div class="dialog" id="user-add">
		<div class="row">
			<label>Username</label>
			<div class="field">
				<input type="text" id="username" />
			</div>
		</div>
		<div class="row">
			<label>Password</label>
			<div class="field">
				<input type="password" id="password" />
			</div>
		</div>
		<div class="row">
			<label>Email</label>
			<div class="field">
				<input type="text" id="email" />
			</div>
		</div>
		<div class="row">
			<label>Full Name</label>
			<div class="field">
				<input type="text" id="full_name" />
			</div>
		</div>
		<div class="row">
			<label>Web Space</label>
			<div class="field">
				<input type="text" id="webspace" /> MB
			</div>
		</div>
		<div class="row">
			<label>User Level</label>
			<div class="field">
				<select id="user_level">
					<option value="0">Activation Required</option>
					<option value="1">Client</option>
					<option value="2">Administrator</option>
				</select>
			</div>
		</div>
		<div class="row">
			<button class="ok-btn">Save</button>
			<button class="cancel-btn">Cancel</button>
		</div>
	</div>
</div>