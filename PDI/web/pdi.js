function testCookie(){
  var cookieValid;
  var tryNumber = 0;
  cookieValid = setInterval(function(){
    console.log('cookie not found! '); 
    //plsql leva algum tempo para gerar o cookie
    if(tryNumber > 200){
      clearInterval(cookieValid);
    }
    if(document.cookie.indexOf('PDIHASH') != -1){
      clearInterval(cookieValid);
      //getReq('telaInicial', document.body, 'false');
      postReq('telaInicial', '').then(function(res){
        if(res.indexOf('no data') == -1){
          document.body.innerHTML = res;
        }
      });
    }
    tryNumber++;
  }, 10);
}

document.addEventListener('click', function(e){
  let alvo = e.target;

  //menu administrativo
  if(alvo.id == 'admin'){
    getReq('admin', document.body, 'false');
  }

  //volta pra tela inicial
  if(alvo.id == 'home'){
    getReq('telaInicial', document.body, 'false');
  }

  //volta pra tela inicial
  if(alvo.id == 'logout'){
    if(confirm('Encerrar acesso?')){
      getReq('logout', document.body, 'false');
    }
  }

  //menu admin, pega proc pelo id
  if(alvo.parentNode.parentNode){
    if(alvo.parentNode.parentNode.id == 'menu-admin'){
      alvo.parentNode.parentNode.querySelector('.selected').classList.remove('selected');
      alvo.parentNode.classList.add('selected');
      getReq(alvo.id, document.getElementById('conteudo'), 'false');
    }
  }

  //get multiple check
  if(alvo.classList.contains('multicheck')){
    let pai = document.getElementById(alvo.getAttribute('data-parent'));
    let filhos = pai.querySelectorAll('input');

    pai.classList.remove('error');

    let arr = [];

    for(let i=0; i<filhos.length; i++){
      if(filhos[i].checked == true){
        arr.push(filhos[i].value);
      }
    }

    pai.title = arr.join('|');
  }

  //post com os gets que estão dentro do formulário
  if(alvo.classList.contains('addpurple') && document.querySelector('.cadastro')){

    //previne duplo clique
    alvo.classList.add('readonly');
    
    let cadastro = document.querySelector('.cadastro');
    
    if(alvo.classList.contains('small')){
      cadastro = document.getElementById('adicionarRelacionamento');
    }
    
    let inputs = cadastro.querySelectorAll('.get');
    let arr = [];
    for(let i=0; i<inputs.length; i++){

      let campo = inputs[i];
      let valor;

      if(typeof campo.value == 'undefined'){
        valor = campo.title;
      } else {
        valor = campo.value;
      }

      //testa tamanho minimo
      if(campo.getAttribute('data-min')){
        if(parseInt(campo.getAttribute('data-min')) > 0){
          if(valor.length < parseInt(campo.getAttribute('data-min'))){
            if(!campo.classList.contains('multibox')){
              campo.setCustomValidity("Favor preencher o campo corretamente!");
              campo.reportValidity();
            }

            campo.classList.add('error');
            alvo.classList.remove('readonly');
            return;
          }
        }
      }

      //codifica texto
      if(campo.getAttribute('data-encode')){
        valor = encodeURIComponent(valor);
      }

      arr.push(campo.id+'='+valor);
    }

    alvo.classList.add('readonly');
    postReq(cadastro.id, arr.join('&')).then(function(res){
      if(res.indexOf('sucesso') != -1){
        alert(res);
        recarregaCadastro('prm_cod='+document.getElementById('prm_cod').value);
      } else {
        if(res.indexOf('value too large') != -1){
          alert('Tamanho muito grande do texto!');
        } else {
          alert('Erro ao salvar!');
        }
        alvo.classList.remove('readonly');
      }
    });
    
  }

  //adicionar relacionamento
  if(alvo.classList.contains('add') && alvo.previousElementSibling.value.length > 0){
    postReq(alvo.getAttribute('data-req'), alvo.getAttribute('data-par')+alvo.previousElementSibling.value).then(function(res){
      if(res.indexOf('sucesso') != -1){
        alert(res);
      }
    });
    recarregaCadastro('prm_cod='+document.getElementById('prm_cod').value);
  }

  //recarrega formulário com o cadastro do usuário
  if(alvo.classList.contains('edit')){
    
    let filtros = retornaFiltros();
    if(filtros.length > 0){
      filtros = '&'+filtros;
    }
    getReq(alvo.getAttribute('data-req')+'?'+alvo.getAttribute('data-par')+filtros, document.getElementById(alvo.getAttribute('data-res')), 'false');
  }

  if(alvo.classList.contains('thumb')){
    //getReq(alvo.getAttribute('data-req')+'?'+alvo.getAttribute('data-par'), document.getElementById(alvo.getAttribute('data-res')), 'false');
    postReq(alvo.getAttribute('data-req'), alvo.getAttribute('data-par')).then(function(res){
      /*if(res.indexOf('sucesso') != -1){
        recarregaCadastro();
      } else {*/
      console.log(res);

      if(res.indexOf('sucesso') == -1){
        alert('Erro ao salvar!');
        alvo.classList.remove('readonly');
      } else {
        if(alvo.getAttribute('data-res')){
          recarregaCadastro();
        }
        console.log(res);
      }
    });
  }

  //limpa formulário
  if(alvo.classList.contains('nova')){
    recarregaCadastro();
  }

  //exclui da lista
  if(alvo.classList.contains('remove')){
    if(confirm('Tem certeza que gostaria de excluir?')){
      postReq(alvo.getAttribute('data-req'), alvo.getAttribute('data-par')).then(function(res){
        if(res.indexOf('sucesso') != -1){
          alert(res);
          recarregaCadastro();
        }
      });
    }
  }

  if(alvo.classList.contains('thumb')){
    if(!alvo.classList.contains('selected')){
      if(alvo.parentNode.querySelector('.thumb.selected')){
        alvo.parentNode.querySelector('.thumb.selected').classList.remove('selected');
      }
      alvo.classList.add('big');
      setTimeout(function(){ alvo.classList.remove('big'); }, 100);
      alvo.classList.add('selected');
    }
  }

  //expande observações
  if(alvo.classList.contains('opendesc')){
    alvo.parentNode.nextElementSibling.classList.toggle('invisible');
  }

  //enviando resposta
  if(alvo.classList.contains('addpurple') && alvo.parentNode.classList.contains('avaliacao')){
    
    //previne duplo clique
    alvo.classList.add('readonly');

    let blocoAvaliacao = alvo.parentNode;
    let respostaMarcada = blocoAvaliacao.querySelector('input:checked');
    let justificativa;
    let valorJustificativa = '';
    let valorResposta = '';
    let pergunta = blocoAvaliacao.title;

    //testa se tem opções, se não só avaliação msm
    if(blocoAvaliacao.querySelector('.opcoes')){
    
      if(!respostaMarcada){
        alvo.classList.remove('readonly');
        return;
      } else {
        valorResposta = respostaMarcada.value;
      }

    }

    //pode não ter justificativa
    if(blocoAvaliacao.querySelector('.justificativa')){
      justificativa = blocoAvaliacao.querySelector('textarea');
      valorJustificativa = encodeURIComponent(justificativa.value);
      //justificativa não precisa ser obrigatória
      if(justificativa.value.length < 1 && !blocoAvaliacao.querySelector('.opcoes')){
        justificativa.setCustomValidity("Favor preencher a justificativa!");
        justificativa.reportValidity();
        alvo.classList.remove('readonly');
        return;
      }
    }

    let avaliado = document.getElementById('avaliado').value;

    var proc = 'adicionarAvaliacao';

    if(document.getElementById('container').classList.contains('lista')){
      proc = 'updateAvaliacao';
    }

    postReq(proc, 'prm_avaliado='+avaliado+'&prm_pergunta='+pergunta+'&prm_valor='+valorResposta+'&prm_justificativa='+valorJustificativa).then(function(res){

      if(!document.getElementById('container').classList.contains('lista')){

        postReq('questao', 'prm_cod=2&prm_avaliado='+avaliado+'&prm_class=next').then(function(resQuestao){

          if(document.getElementById('container').querySelector('.previous')){
            document.getElementById('container').querySelector('.previous').remove();
          }

          let temp = document.createElement('div');
          temp.innerHTML = resQuestao;

          document.getElementById('container').appendChild(temp.children[0]);

        }).then(function(){

          //movimento do questionario
          let questao = alvo.parentNode.parentNode; 
          questao.classList.add('previous'); 
          questao.nextElementSibling.classList.remove('next');

          //movimento do progresso
          let andamento  = document.getElementById('andamento');
          let incremento = parseFloat(andamento.getAttribute('data-parte'));
          let atual      = parseFloat(andamento.getAttribute('data-atual'));
          atual = atual+incremento;
          andamento.style.setProperty('width', atual+'%');
          andamento.setAttribute('data-atual', atual);

          //proxima bolinha marcada
          setTimeout(function(){
            let current = document.getElementById('progresso').querySelector('.current');
            current.classList.remove('current');
            current.classList.add('preenchida');

            if(parseInt(document.getElementById('progresso').title) == document.getElementById('progresso').querySelectorAll('.preenchida').length){
              setTimeout(function(){
                getReq('telaInicial', document.body, 'false');
              }, 5000);
            } else {
              current.nextElementSibling.classList.add('current');
            }
          }, 200);

        });

      } else {
        alert(res);
        alvo.classList.remove('readonly');
        if(res.indexOf('sucesso') != -1){
          alvo.parentNode.classList.add('salvo');
        }
      }

    });

  }

  if(alvo.parentNode.classList.contains('setor') && alvo.parentNode.parentNode.classList.contains('opcoes')){
    if(document.getElementById('menudeavaliacoes').querySelector('.opcoes.selected')){
      let anterior = document.getElementById('menudeavaliacoes').querySelector('.opcoes.selected');
      setTimeout(function(){
        anterior.classList.remove('selected');
      }, 300);
    }
    alvo.parentNode.parentNode.classList.add('selected');
  }

  if(alvo.parentNode.classList.contains('nome') && alvo.parentNode.parentNode.classList.contains('opcoes')){

    if(document.getElementById('menudeavaliacoes').querySelector('.nome.selected')){
      document.getElementById('menudeavaliacoes').querySelector('.nome.selected').classList.remove('selected');
    }
    alvo.parentNode.classList.add('selected');

    document.getElementById('conteudo').classList.add('loading');
    setTimeout(function(){
      postReq('avaliacao', 'prm_avaliado='+alvo.title).then(function(res){
        document.getElementById('conteudo').classList.add('loaded');
        document.getElementById('conteudo').innerHTML = res;
        
        setTimeout(function(){
          document.getElementById('conteudo').className = '';
          
        }, 600);
      });
    }, 100);
  }

  if(alvo.parentNode.id == 'login'){
    postReq('avaliacao', 'prm_avaliado='+alvo.title).then(function(res){
      document.getElementById('container').innerHTML = res;
    });
  }

});

document.addEventListener('input', function(e){
  let alvo = e.target;
  if(alvo.classList.contains('get')){
    alvo.classList.remove('error');
    alvo.setCustomValidity("");
  }
});


//filtro de perguntas
document.addEventListener('change', function(e){
  if(e.target.classList.contains('filtro')){
    recarregaCadastro(retornaFiltros());
  }
});

function retornaFiltros(){
  if(document.querySelector('.filtro')){

    let filtros = document.querySelectorAll('.filtro');
    let arr = [];

    for(let i=0; i<filtros.length; i++){
      arr.push(filtros[i].id+'='+filtros[i].value);
    }

    return arr.join('&');

  } else {
    return '';
  }
}


//lista de relacionamentos
document.addEventListener('dblclick', function(e){
  
  let alvo = e.target;
  
  if(alvo.parentNode.classList.contains('multiple')){
    if(confirm('Tem certeza que gostaria de excluir?')){
      postReq(alvo.parentNode.getAttribute('data-req'), 'prm_cod='+alvo.value).then(function(res){
        if(res.indexOf('sucesso') != -1){
          recarregaCadastro('prm_cod='+document.getElementById('prm_cod').value);
          alert(res);
        }
      });
    }
  }
});

function recarregaCadastro(par){
  document.getElementById('conteudo').classList.add('loading');
  setTimeout(function(){

    if(document.querySelector('.small')){
      document.querySelector('.limit').querySelector('.selected').querySelector('.ligacao').click();
      document.getElementById('conteudo').classList.add('loaded');
      setTimeout(function(){
        document.getElementById('conteudo').className = '';
      }, 600);
    } else {
      var req = document.getElementById('menu-admin').querySelector('.selected').children[0].id;
      postReq(req, par).then(function(res){
        document.getElementById('conteudo').classList.add('loaded');
        document.getElementById('conteudo').innerHTML = res;
        setTimeout(function(){
          document.getElementById('conteudo').className = '';
        }, 600);
      });
    }
  }, 200);
}


function getReq(req, alvo, async){
	var ajaxRequest;
	ajaxRequest = new XMLHttpRequest();
	
  ajaxRequest.onreadystatechange = function(){
		if(ajaxRequest.readyState == 4){
      alvo.innerHTML = ajaxRequest.responseText;
		}
	}

  ajaxRequest.open("GET", 'dwu.pdi.'+req, async);
  ajaxRequest.setRequestHeader("Cache-Control", "private, no-cache, no-store, must-revalidate");
	ajaxRequest.send(null);
}

function postReq(req, par){
  return new Promise(function(resolve, reject){
    var request = new XMLHttpRequest();
    request.open('POST', 'dwu.pdi.'+req, true);
      
    request.send(par);
    
    request.onload = function(){
      if(request.status == 200){
        resolve(request.responseText.trim());
      } else {
        reject(console.log('erro'));
      }
    }

    request.onerror = function(){
      console.log('erro')
    }
  });
} 