TOCCreator = {
  Header: function(level, text, visible, id){
    var obj = {
      level: level,
      text: text,
      id: id,
      visible: visible,
      childs: [],
      mother: null,

      add_child: function(child){
        this.childs.push(child);
        child.mother = this;
      },

      to_html: function(out){
        var ol, li, a;

        if(this.visible){
            li = document.createElement('li');
            a = document.createElement('a');
            a.innerHTML = this.text;
            a.href = '#' + this.id;
            li.appendChild(a);
            out.appendChild(li);

          if(this.childs.length > 0){
            ol = document.createElement('ol');
            li.appendChild(ol);

            this.each_child_to_html(ol);
          }
        } else {
          ol = document.createElement('ol');
          out.appendChild(ol);
          this.each_child_to_html(ol);
        }

        return(out);
      },

      each_child_to_html: function(root){
        for(child_i in this.childs){
          this.childs[child_i].to_html(root);
        }
      }
    };

    return(obj);
  },

  elements_by_tag_names: function(list, given_doc){
    var doc = (doc || document);
    var tag_names = list.split(',');
    var tags = [];

    for(tag_names_i in tag_names){
      var partials = doc.getElementsByTagName(tag_names[tag_names_i]);

      for(i = 0; i < partials.length; i++){
        tags.push(partials[i]);
      }
    }

    var test_node = tags[0];

    if(!test_node){
      return([]);
    } else if(test_node.sourceIndex){
      tags.sort(function(a, b){ return(a.sourceIndex - b.sourceIndex); });
    } else if(test_node.compareDocumentPosition){
      tags.sort(function(a, b){ return(3 - (a.compareDocumentPosition(b) & 6)); });
    }

    return(tags);
  },

  collect_headers: function(given_levels, doc){
    var levels = (given_levels || 'h1,h2,h3,h4,h5');
    var headers = [];
    var tags = this.elements_by_tag_names(levels, doc);

    for(tag_i in tags){
      var tag, level, text, id

      tag = tags[tag_i];
      level = tag.nodeName.match('H(\\d+)')[1];
      text = tag.innerHTML;

      if(tag.id){
        id = tag.id;
      } else {
        id = 'toc_' + tag_i;
        tag.id = id;
      }

      headers.push({toclevel: level, text: text, id: id});
    }

    return(headers);
  },

  generate_ast: function(doc){
    var headers = this.collect_headers(doc);
    var original_root = new this.Header(1, 'ROOT', false);
    var root = original_root;
    root.mother = root;

    for(header_i in headers){
      var element = headers[header_i];
      var header = new this.Header(element.toclevel, element.text, true, element.id);
      var temp = root;
      var i;

      if(header.level == root.level){
        root.mother.add_child(header);
      } else if(header.level > root.level){
        for(i = (header.level - 1); i > root.level; i--){
          var temp_child = new this.Header(i, 'TEMP', false);
          temp.add_child(temp_child);
          temp = temp_child;
        }

        temp.add_child(header);
      } else if(header.level < root.level){
        for(i = header.level; i <= root.level; i++){
          var temp_mother = temp.mother;
          temp = temp_mother;
        }

        temp.add_child(header);
      }

      root = header;
    }

    return(original_root);
  }
};

function generateToc(n){
  var root = document.getElementById('toc');
  var ast = TOCCreator.generate_ast();
  ast.to_html(root);
}
