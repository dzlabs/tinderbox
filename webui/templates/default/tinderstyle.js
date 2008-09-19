/**
 * setProperty()
 */
var setProperty = function(name, value)
{
	var expires = new Date();
	expires.setDate(expires.getDate() + 365);
	expires = expires.toGMTString();
	document.cookie = name + '=' + escape(value) + '; expires=' + expires;
}

/**
 * getProperty()
 */
var getProperty = function(name)
{
	if (document.cookie.length < 1)
		return false;

	var cArr = document.cookie.split('; ');

	for (var i = 0; i < cArr.length; i++) {
		var eq = cArr[i].indexOf('=');
		if (cArr[i].substring(0, eq) == name)
			return unescape(cArr[i].substring(eq + 1));
	}

	return false;
}

var log_lines = [];

/**
 * log_show()
 */
var log_show = function(severity, action)
{
	if (typeof severity == 'object') {
		severity = this.id;
		action = this.checked;
	}
	if (severity == 'linenumber') {
		var display = action ? '' : 'none';
		for (var i = 0; i < log_lines.length; i++)
			log_lines[i][0].style.display = display;
	}
	else {
		document.getElementById(severity+'_table').style.display = action ? '' : 'none';
		for (var lnr in log_colorlines[severity])
			log_lines[lnr][1].style.color = action ? log_colorlines[severity][lnr] : '';
	}

	setProperty(severity, action ? 1 : 0);
}

/**
 * log_ini()
 */
var log_ini = function()
{
	var table = document.getElementById('log_table'), tbody, lnr, switches;

	for (var i = 0; i < table.childNodes.length; i++) {
		if (table.childNodes[i].tagName != 'TBODY')
			continue;
		tbody = table.childNodes[i];
	}

	for (var i = 0; i < tbody.childNodes.length; i++) {
		if (tbody.childNodes[i].tagName != 'TR')	
			continue;

		lnr = tbody.childNodes[i].id.replace(/^l/, '');
		log_lines[lnr] = [];

		for (var j = 0; j < tbody.childNodes[i].childNodes.length; j++) {
			if (tbody.childNodes[i].childNodes[j].tagName != 'TH'
			&& tbody.childNodes[i].childNodes[j].tagName != 'TD')
				continue;

			log_lines[lnr].push(tbody.childNodes[i].childNodes[j]);
		}
	}

	switches = document.getElementsByTagName('input');
	for (var i = 0; i < switches.length; i++)
		switches[i].onclick = log_show;
}
