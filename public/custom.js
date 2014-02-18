Xhr.Options.spinner = 'spinner';

var xhrClass = new Xhr('/get_classes');
xhrClass.onComplete(function() {
  $('class_div').update(this.text);
});

var xhrCourse = new Xhr('/get_course');
xhrCourse.onComplete(function() {
    $('course_div').update(this.text);
});

var xhrCourse1 = new Xhr('/get_course_in_course');
xhrCourse1.onComplete(function() {
    $('course_div').update(this.text);
});

var xhrStud = new Xhr('/get_students');
xhrStud.onComplete(function() {
    $('students_div').update(this.text);
});

function grade_changed(all_stud){
  var gradeVal = $('grade_select').getValue()
  xhrClass.send({grade_select:gradeVal, all_stud:all_stud})
  xhrCourse.send({grade_select:gradeVal})
  var classVal = $('class_select').getValue()
  xhrStud.send({class_select:classVal})
}

function grade_changed_in_course(){
  var gradeVal = $('grade_select').getValue()
  xhrCourse1.send({grade_select:gradeVal})
}

function class_changed(all_stud){
  var classVal = $('class_select').getValue()
  xhrStud.send({class_select:classVal, all_stud:all_stud})
}

function student_changed(){
  var gradeVal = $('grade_select').getValue()
  var studentVal = $('student_select').getValue()
  xhrCourse.send({grade_select:gradeVal, student_select:studentVal})
}

function checkDup(arr){
  for(var i=0; i<arr.length; i++){
    for (var j=i+1; j<arr.length; j++){
      if (arr[i]==arr[j]){
        return true;
      }
    }
  }
  return false;
}

"#grade_form".onSubmit(function(event) {
  event.stop();
  var me = this
  var nameArr = []
  var cntxArr = []
  $$('input').filter('checked').each(function(obj){
    var name = obj.get('name')
    if (/^N\_(\d+)$/.test(name)){
        name = RegExp.$1
    }
    nameArr.push(name)
    cntxArr.push(obj.parent().next().text())
  })

  var arr = []
  for (var i=0; i<nameArr.length; i++){
    arr.push('第'+nameArr[i]+'期 : '+cntxArr[i])
  }

  if (nameArr.length!='#tRound'.getValue()){ //没有选满期
    new Dialog.Alert()
      .html("课程期数没有选满：<br>"+arr.join('<br>'))
      .onOk()
      .show();
  }else if (checkDup(cntxArr)){
    new Dialog.Alert()
      .html("你的选择有重复：<br>"+arr.join('<br>'))
      .onOk()
      .show();
  }else{
    new Dialog.Confirm()
      .html("请确认你的选择：<br>"+arr.join('<br>'))
      .onOk(function(){
          me.send({
            onSuccess: function() {
              // $('msg_div').update(me.responseText);
            }
          })
          new Dialog.Alert().html("选择完成。").onOk(function(){setTimeout("window.location='"+ loc+"'" , 1000)}).show();
      })
      .onCancel()
      .show();
  }

  // if (confirm('保存？')){
  //   this.send({
  //     onSuccess: function() {
  //       // alert(this.to_json);
  //       $('msg_div').update(this.responseText);
  //     }
  //   });

  //   // var gradeVal = $('grade_select').getValue()
  //   // var classVal = $('class_select').getValue()
  //   // var all_stud = $('all_stud').getValue()
  //   // xhrStud.send({class_select:classVal, all_stud:all_stud})
  //   // xhrCourse.send({grade_select:gradeVal})//, student_select:-1})
  //   // xhrCourse.send({grade_select: '-1'})
  //   setTimeout("window.location='/'", 1000)
  // }
});

"#course_form".onSubmit(function(event) {
  event.stop();

  if (confirm('保存选择？')){
    this.send({
      onSuccess: function() {
        $('msg_div').update(this.responseText);
      }
    });
  }
});


