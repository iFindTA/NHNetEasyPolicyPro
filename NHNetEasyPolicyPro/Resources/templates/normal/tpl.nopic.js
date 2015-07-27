/**
 * 无图模式模板
 * @authors sjd@gongshidai.com
 * @date    2015-07-24 09:49:57
 */
window.template = '\
		<h1 class="title">{{=it.title}}</h1>\
		<div class="intro">{{=it.intro}}</div>\
		<div class="content">{{=it.body}}</div>\
		<div class="note">\
			<div class="author">作者：{{=it.note.author}}</div>\
			<div class="note-row">时间：{{=it.note.date}}</div>\
		</div>\
		<div class="relate">相关阅读</div>\
		{{ for(var i in it.relevant) { var item = it.relevant[i]; }}\
		<div class="relate-item" onclick="getRelateDetail({{=item.id}})" >\
			<div class="relate-inner">\
				<span class="relate-title">{{=item.title}}</span>\
				<span class="relate-intro">{{=item.intro}}</span>\
			</div>\
		</div>\
		{{ } }}';