# 根据xxx.widget.detail.spec（json）对象，生成form中的fieldset对象。一个widget就对应到一个fieldset。
define 'table-semantic-ui-dom-creator', [], ->
  create: (@spec)->
    @table = $ "<table class='ui table' data-b-plus-model-widget='#{spec.name}'></table>"
    @add-head!
    @add-template-row!
    [@table, @template-row]

  add-head: !->
    @table.append ($ "<thead></thead>" .append (tr = $ '<tr></tr>' ))
    for column in @spec.columns
      class-str = if column.class then "class='#{column.class}'" else ''
      tr.append "<th #{class-str}>#{@get-cloumn-name column.name}</th>"
    @add-operation-column-head tr

  get-cloumn-name: (name)-> # 对于形如："贷款申请.申请金额"的情况，取.之后部分"申请金额"
    [..., last] = name.split '.'
    last

  add-operation-column-head: (tr)->
    tr.append $ "<th class='a-plus operation delete'> 操作 </th> "

  add-template-row: !->
    @template-row = $ "
      <tr data-b-plus-list-item-template='#{@spec.item-template-name}' style='display: none'>
        <input type='hidden' data-a-plus-bind='_id'/>
      </tr>
      "
    @table.append ($ "<tbody></tbody>" .append @template-row)
    for column in @spec.columns
      if column.type is 'action'
        '' # TODO: insert action buttons
      else
        td = $ "<td data-a-plus-bind='#{column.bind}'>-</td>"
        td.attr 'data-a-plus-computation', '' if column.is-computed
        @template-row.append td
    @add-operation-column! 

  add-operation-column: !->
    @template-row.append td = $ '''
      <td class='a-plus operation delete'>
        <i class='remove icon' title='删除'></i>
      </td>
    '''
