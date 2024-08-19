tryagain = 0;

function last(){
 x = document.getElementsByTagName('ul').length;
 document.getElementById('avaliados').childNodes[x].className= document.getElementById('avaliados').childNodes[x].className + ' last';
}

function inject_html(x){
	var ajaxRequest;
	ajaxRequest = new XMLHttpRequest();
	
  ajaxRequest.onreadystatechange = function(){
		if(ajaxRequest.readyState == 4){
      document.getElementById('conteudo').innerHTML = ajaxRequest.responseText;
		}
	}
  ajaxRequest.open("GET", (x), true);
  ajaxRequest.setRequestHeader("Cache-Control", "private, no-cache, no-store, must-revalidate");
	ajaxRequest.send(null);
}

function inject_edit(x){
  var ajaxRequest;
  ajaxRequest = new XMLHttpRequest();
  
  ajaxRequest.onreadystatechange = function(){
    if(ajaxRequest.readyState == 4){
      document.getElementById('edit-form').innerHTML = ajaxRequest.responseText;
    }
  }
  ajaxRequest.open("GET", (x), true);
  ajaxRequest.setRequestHeader("Cache-Control", "private, no-cache, no-store, must-revalidate");
  ajaxRequest.send(null);
}

function insert_question(x, y){
	var ajaxRequest;
  ajaxRequest = new XMLHttpRequest();
  ajaxRequest.onreadystatechange = function(){
		if(ajaxRequest.readyState == 4){
      check = ajaxRequest.responseText;;
      if(check.indexOf('!ADD') != -1){
          alerta('alerta', tr_ad);
      } else {
        if(check.indexOf('!DUPLICADO') != -1){
          alerta('alerta', tr_dp);
        } else {
          alerta('alerta', tr_er);
        }
      }
      if(check.indexOf('!DLT') != -1){
        alerta('alerta', tr_ex);
      }
		}
	}
  ajaxRequest.open("POST", (x), false);
  ajaxRequest.setRequestHeader("Cache-Control", "private, no-cache, no-store, must-revalidate");
	ajaxRequest.send(y);
}

function inject_db(x){
	var ajaxRequest;
	ajaxRequest = new XMLHttpRequest();
  
  ajaxRequest.open("GET", (x), false);
  ajaxRequest.setRequestHeader("Cache-Control", "private, no-cache, no-store, must-revalidate");
	ajaxRequest.send(null);
	
	
}

function inserir(param, z){
	call('inserir', param, 'sac').then(function(resposta){
		if(resposta.indexOf('OK') != -1){
			
			if(document.getElementById('perguntas').childElementCount == 0){ 
        document.getElementById('completo').setAttribute('class','linha visivel'); 
        //inject_db('dwu.sac.fechar?avaliacao='+x); 
        inject_db('felipe.sac_2.fechar?avaliacao='+x); 
      }
		}
	});
}

function check_sac(x, y, z){
    var ajaxRequest;
	  ajaxRequest = new XMLHttpRequest();

    ajaxRequest.onreadystatechange = function(){
	    if(ajaxRequest.readyState == 4){
        var count = ajaxRequest.responseText;
        if(ajaxRequest.status == 200){ 
          if(parseInt(count) > 0){
            tryagain = 0;
            document.getElementById(z).setAttribute('class', 'invisivel');
            setTimeout(function(){ var destroi = document.getElementById(z); destroi.parentNode.removeChild(destroi); }, 300);
            setTimeout(function(){
              if(document.getElementById('perguntas').childElementCount == 0){ 
                document.getElementById('completo').setAttribute('class','linha visivel'); 
                //inject_db('dwu.sac.fechar?avaliacao='+x);
                inject_db('felipe.sac_2.fechar?avaliacao='+x); 
              }
            }, 300);
          } else { 
            if(tryagain < 10){
              setTimeout(function(){
                tryagain = tryagain+1;
                check_sac(x, y, z);
              }, 1000);    
            } 
          } 
        }
		  }
	  }
    //ajaxRequest.open("GET", ('dwu.sac.check_nota?prm_avaliacao='+x+'&prm_questao='+y), false);
    ajaxRequest.open("GET", ('felipe.sac_2.check_nota?prm_avaliacao='+x+'&prm_questao='+y), false);
    ajaxRequest.setRequestHeader("Cache-Control", "private, no-cache, no-store, must-revalidate");
	  ajaxRequest.send(null);
}

function validate(questao, profissional, avaliacao, count, total){
  x = document.getElementById(questao+'-'+profissional+'-nota').elements['nota'];
  y = document.getElementById(questao+'-'+profissional+'-comentario');
  for(i=0;i<x.length;i++){ 
    if(x[i].checked){
      if(parseInt(x[i].value) < 7){
        if(y.value=='Digite seu comentário' || y.value==''){
          document.getElementById(questao+'-'+profissional+'-alerta').className='ativo';
        } else {
          document.getElementById(questao+'-'+profissional+'-alerta').className='invisivel';
          this.text='Concluido!'; 
          this.className='concluido';
          document.getElementById(questao+'-'+profissional+'-campo').className='invisivel';
          //inject_db('dwu.sai.inserir?avaliacao='+avaliacao+'&questao='+questao+'&nota='+x[i].value+'&obs='+y.value); 
          inject_db('dwu.sai.inserir?avaliacao='+avaliacao+'&questao='+questao+'&nota='+x[i].value+'&obs='+y.value); 
        }
      } else {
        document.getElementById(questao+'-'+profissional+'-alerta').className='invisivel';
        this.text='Concluido!'; 
        this.className='concluido';
        document.getElementById(questao+'-'+profissional+'-campo').className='invisivel';
        if(y.value=='Digite seu comentário'){ y.value=''; }
        if(parseInt(x[i].value) == 99){ x[i].value = ''; }
        inject_db('dwu.sai.inserir?avaliacao='+avaliacao+'&questao='+questao+'&nota='+x[i].value+'&obs='+y.value);
      }
    }
  }
  z =  document.getElementsByClassName('concluir '+count).length;
  if(z == 0){ 
    document.getElementById('avaliar-'+count).innerHTML = '<span>Avaliado</span>';
    document.getElementById(profissional+'-questoes').className='invisivel';
    inject_db('dwu.sai.fechar?avaliacao='+avaliaca0);
    if(count == total){ document.getElementById('completo').className='visivel'; } 
  }
}
function alerta(x, msg) {
  if(msg) {
   if(document.getElementById(x)) { 
     document.getElementById(x).innerHTML = msg;
     document.getElementById(x).style.opacity = '1';
     setTimeout(function(){ document.getElementById(x).style.opacity = '0'; }, 2000);
   }
 }
}