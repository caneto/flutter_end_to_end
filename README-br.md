 
# Flutter de ponta a ponta
Um projeto Flutter destinado a aprender o desenvolvimento de aplicativos em várias plataformas usando uma base de código unificada.

# Recursos atualmente disponíveis:
1. Tema
2. Roteamento
3. Localização
4. Suporte off-line usando o plug-in Sqflite
5. Padrão de bloco
6. Deep Linking
7. Notificação por push local e remota


# Plataformas atualmente suportadas:
- Android

# Tema:
   * Nesse aplicativo, foi implementado o tema Material 3, no qual é possível encontrar diferentes tipos de componentes materiais.
   * Implementamos os modos de tema claro e escuro, que também mudam de acordo com as configurações do sistema.
   * Para obter mais informações, siga os links abaixo

# Roteamento:
   * Toda a navegação desse aplicativo foi implementada usando o pacote **GoRouter**.
   * Ele é compatível com todas as plataformas suportadas pelo Flutter.
   * Este aplicativo suporta navegação aninhada.
   * Implementamos a navegação Parent com vários filhos, mas estamos tendo alguns problemas ao tocar no botão de retorno do dispositivo, o que será resolvido em breve.

# Arquitetura limpa usando o padrão Flutter Bloc:
   * Para explicar brevemente sobre o bloco, criamos um módulo chamado **Schools**, usando esse módulo podemos criar uma escola, um aluno e mais informações sobre a escola, além de adicionar uma opção de exclusão.
   * Todo o processo de criação, edição e exclusão de entidades é implementado usando exclusivamente o Bloc.
   * Ele explicará como separar as pastas e como será o fluxo através delas.
   * Estamos utilizando o Firebase Realtime Database para implementar operações CRUD
      
# Suporte off-line: 
   * O módulo escolar desenvolvido com o flutter Bloc pode armazenar os dados no banco de dados local, o que foi implementado com o uso do banco de dados SQLite.
   * Ele tem três modos de tipo diferentes, com base no modo selecionado em que os dados serão armazenados.
     -  Modo off-line:**
       Armazena os dados no banco de dados local somente quando não há internet. Quando a Internet voltar, os dados serão sincronizados automaticamente com o servidor e excluirão os dados locais
     -  Modo on-line e off-line
       Independentemente da Internet, os dados serão armazenados no banco de dados local e serão excluídos com base na data configurada.
     -  Despejo de dados off-line:**
       Os dados serão despejados no banco de dados local no momento do login ou do carregamento do módulo. Posteriormente, eles serão usados para fazer algumas operações    
  * Quando a Internet estiver disponível, os dados serão automaticamente carregados no servidor usando o pacote Connectivity plus.
  * Atualmente, as plataformas off-line suportadas são iOS, Android e macOS. 

# Deep Linking:
  * Este aplicativo oferece suporte a deep linking, implementado exclusivamente com o uso de documentos oficiais do flutter
    https://docs.flutter.dev/ui/navigation/deep-linking
  * Atualmente, o Deep linking é compatível com as plataformas iOS, Android e macOS.
      
**Link de referência:** [https://docs.flutter.dev/ui/navigation/deep-linking](https://docs.flutter.dev/ui/navigation/deep-linking)  

#  Notificação por push - remota e local:
  ## Notificação por push remota:
  * As notificações por push são integradas usando o Firebase.
  * Atualmente, as notificações por push são compatíveis com as plataformas Android, iOS, macOS e Web.   

**Link de referência:** https://firebase.google.com/docs/cloud-messaging/flutter/client    

 ## Notificação por push local:
 * As notificações locais são integradas usando **flutter_local_notifications**.
 * Atualmente, as notificações push locais são compatíveis com as plataformas Android, iOS, macOS e Linux.

**Link de referência:** https://pub.dev/packages/flutter_local_notifications#-supported-platforms    

