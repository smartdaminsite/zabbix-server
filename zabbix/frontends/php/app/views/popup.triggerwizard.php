<?php
/*
** Zabbix
** Copyright (C) 2001-2019 Zabbix SIA
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/


$options = $data['options'];
$output = [
	'header' => $data['title'],
	'script_inline' => require 'app/views/popup.triggerwizard.js.php'
];

// SID for this form is added by JS getUrl() and "form_refresh" is not used at all.
$form = (new CForm('post', 'zabbix.php'))
	->cleanItems()
	->setName('sform')
	->addVar('sform', '1')
	->addVar('action', 'popup.triggerwizard')
	->addVar('itemid', $options['itemid'])
	->addItem((new CInput('submit', 'submit'))->addStyle('display: none;'));

if (array_key_exists('triggerid', $options)) {
	$form->addVar('triggerid', $options['triggerid']);
}

$expression_table = (new CTable())
	->addClass('ui-sortable')
	->setId('expressions_list')
	->setAttribute('style', 'width: 100%;')
	->setHeader([
		'',
		_('Expression'),
		_('Type'),
		_('Action')
	]);

$expressions = [];

foreach ($data['expressions'] as $expr) {
	$expressions[] = [
		'expression' => $expr['value'],
		'type_label' => $expr['type'] == CTextTriggerConstructor::EXPRESSION_TYPE_MATCH ? _('Include') : _('Exclude'),
		'type' => $expr['type']
	];
}

$output['script_inline'] = 'jQuery("#'.$expression_table->getId().'").data("rows", '.CJs::encodeJson($expressions).');'
	.$output['script_inline'];

$form->addItem(
	(new CFormList())
		->addRow(
			(new CLabel(_('Name'), 'description'))->setAsteriskMark(),
			(new CTextBox('description', $options['description']))
				->setAriaRequired()
				->setWidth(ZBX_TEXTAREA_STANDARD_WIDTH)
		)
		->addRow(
			new CLabel(_('Operational data'), 'opdata'),
			(new CTextBox('opdata', $options['opdata']))->setWidth(ZBX_TEXTAREA_STANDARD_WIDTH)
		)
		->addRow(_('Item'), [
			(new CTextBox('item', $options['item_name']))
				->setWidth(ZBX_TEXTAREA_STANDARD_WIDTH)
				->setAttribute('disabled', 'disabled'),
			(new CDiv())->addClass(ZBX_STYLE_FORM_INPUT_MARGIN),
			(new CButton(null, _('Select')))
				->addClass(ZBX_STYLE_BTN_GREY)
				->onClick('return PopUp("popup.generic",'.
					CJs::encodeJson([
						'srctbl' => 'items',
						'srcfld1' => 'itemid',
						'srcfld2' => 'name',
						'dstfrm' => $form->getName(),
						'dstfld1' => 'itemid',
						'dstfld2' => 'item'
					]).', null, this);'
				)
		])
		->addRow(_('Severity'), new CSeverity([
			'name' => 'priority',
			'value' => (int) $options['priority']
		]))
		->addRow((new CLabel(_('Expression'), $expression_table->getId()))->setAsteriskMark(),
			(new CTextBox('expression'))
				->setWidth(ZBX_TEXTAREA_STANDARD_WIDTH)
				->setId('logexpr')
		)
		->addRow(null, [
			(new CCheckBox('iregexp'))->setLabel('iregexp'),
			(new CDiv())->addClass(ZBX_STYLE_FORM_INPUT_MARGIN),
			(new CButton('add_key_and', _('AND')))->addClass(ZBX_STYLE_BTN_GREY),
			(new CDiv())->addClass(ZBX_STYLE_FORM_INPUT_MARGIN),
			(new CButton('add_key_or', _('OR')))->addClass(ZBX_STYLE_BTN_GREY),
			(new CDiv())->addClass(ZBX_STYLE_FORM_INPUT_MARGIN),
			(new CComboBox('expr_type', null, null, [
				CTextTriggerConstructor::EXPRESSION_TYPE_MATCH => _('Include'),
				CTextTriggerConstructor::EXPRESSION_TYPE_NO_MATCH => _('Exclude')
			]))->setId('expr_type'),
			(new CDiv())->addClass(ZBX_STYLE_FORM_INPUT_MARGIN),
			(new CButton('add_exp', _('Add')))->addClass(ZBX_STYLE_BTN_GREY)
		])
		->addRow(null,
			(new CDiv((new CTable())
				->setId('key_list')
				->setAttribute('style', 'width: 100%;')
				->setHeader([
					_('Keyword'),
					_('Type'),
					_('Action')
				])
			))
				->addClass(ZBX_STYLE_TABLE_FORMS_SEPARATOR)
				->setAttribute('style', 'min-width: '.ZBX_TEXTAREA_BIG_WIDTH.'px;')
		)
		->addRow(null,
			(new CDiv($expression_table))
				->addClass(ZBX_STYLE_TABLE_FORMS_SEPARATOR)
				->setAttribute('style', 'min-width: '.ZBX_TEXTAREA_BIG_WIDTH.'px;')
		)
		->addRow(_('URL'), (new CTextBox('url', $options['url']))->setWidth(ZBX_TEXTAREA_STANDARD_WIDTH))
		->addRow(_('Description'),
			(new CTextArea('comments', $options['comments']))->setWidth(ZBX_TEXTAREA_STANDARD_WIDTH)
		)
		->addRow(_('Enabled'),
			(new CCheckBox('status'))->setChecked($options['status'] == TRIGGER_STATUS_ENABLED)
		)
);

$output['body'] = $form->toString();

$output['buttons'] = [[
	'title' => array_key_exists('triggerid', $options) ? _('Update') : _('Add'),
	'class' => '',
	'keepOpen' => true,
	'isSubmit' => true,
	'action' => 'return validateTriggerWizard("'.$form->getName().'", '.
					'jQuery(window.document.forms["'.$form->getName().'"])'.
						'.closest("[data-dialogueid]")'.
						'.attr("data-dialogueid")'.
				');'
]];

if ($data['user']['debug_mode'] == GROUP_DEBUG_MODE_ENABLED) {
	CProfiler::getInstance()->stop();
	$output['debug'] = CProfiler::getInstance()->make()->toString();
}

echo (new CJson())->encode($output);
