{*
* 2007-2013 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2013 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}

{extends file="helpers/form/form.tpl"}

{block name="label"}
	{if $input['type'] == 'modules'}
		<div style="{if !$form_id}display:none{/if}">
			<label class="control-label col-lg-3">{l s='Authorized modules:'}</label>
		</div>
	{elseif $input['type'] == 'group_discount_category'}
		<div style="{if !$form_id}display:none{/if}">
			{$smarty.block.parent}
		</div>
	{else}
		{$smarty.block.parent}
	{/if}
{/block}


{block name="field"}
	{if $input['type'] == 'group_discount_category'}
	<div style="{if !$form_id}display:none{/if}">
		<script type="text/javascript">
		$(document).ready(function() {
			$("#group_discount_category").fancybox({
				onStart: function () {
					$('#group_discount_category_fancybox').show();
					initFancyBox();
				},
				onClosed: function () {
					$('#group_discount_category_fancybox').hide();
				}
			});
		});
		
		function deleteCategoryReduction(id_category)
		{
			$('#group_discount_category_table tr#'+id_category).fadeOut('slow', function () {
				$(this).remove();	
			});
		
		}
		
		function addCategoryReduction() 
		{
			exist = false;
			$('.category_reduction').each( function () {
				if ($(this).attr('name') == 'category_reduction['+$('[name="id_category"]:checked').val()+']')
				{
					exist = true;
					jAlert('{l s='This category already exists for this group.' js=1}');
					return false;
				}
			});
			
			if (exist)
				return;
			$.ajax({
				type:"POST",
				url: "ajax-tab.php",
				async: true,
				dataType: "json",
				data : {
					ajax: "1",
					token: "{getAdminToken tab='AdminGroups'}",
					controller: "AdminGroups",
					action: "addCategoryReduction",
					category_reduction: $('#category_reduction_fancybox').val() ,
					id_category: $('[name="id_category"]:checked').val()
				},
				success : function(jsonData) {
					if (jsonData.hasError)
					{
						var errors = '';
						for (error in jsonData.errors)
							//IE6 bug fix
							if (error != 'indexOf')
								errors += $('<div />').html(jsonData.errors[error]).text() + "\n";
						jAlert(errors);
					}
					else
					{
						$('#group_discount_category_table').append('<tr class="alt_row" id="'+jsonData.id_category+'"><td>'+jsonData.catPath+'</td><td>{l s='Discount:'}'+jsonData.discount+'{l s='%'}</td><td><a href="#" onclick="deleteCategoryReduction('+jsonData.id_category+');"><img src="../img/admin/delete.gif"></a></td></tr>');
						
						var input_hidden = document.createElement("input");
						input_hidden.setAttribute('type', 'hidden');
						input_hidden.setAttribute('value', jsonData.discount);
						input_hidden.setAttribute('name', 'category_reduction['+jsonData.id_category+']');
						input_hidden.setAttribute('class', 'category_reduction');
						
						$('#group_discount_category_table tr#'+jsonData.id_category+' > td:last').append(input_hidden);
						$.fancybox.close();
					}
				}
			});
			
			return false;
		}
			
		function initFancyBox()
		{
			$('[name="id_category"]:checked').removeAttr('checked');
			collapseAllCategories();
			$('#category_reduction_fancybox').val('0.00');
		}
		</script>

		<div class="col-lg-9">
			<a class="btn btn-default" href="#group_discount_category_fancybox" id="group_discount_category">{l s='Add a category discount'}</a>
			<table class="table" id="group_discount_category_table">
				{foreach $input['values'] key=key item=category }
					<tr class="alt_row" id="{$category.id_category}">
						<td>{$category.path}</td>
						<td>{l s='Discount: %d%%' sprintf=$category.reduction}</td>
						<td>
							<a href="#" onclick="deleteCategoryReduction({$category.id_category});">
								<img src="../img/admin/delete.gif">
							</a>
							<input type="hidden" class="category_reduction" name="category_reduction[{$category.id_category}]" value="{$category.reduction}">
						</td>
					</tr>
				{/foreach}
			</table>
		
		<div style="display:none" id="group_discount_category_fancybox">
			<fieldset class="form-horizontal">
				<div class="col-lg-12">
					<h3><i class="icon-group"></i> {l s='New group category discount'}</h3>
					<hr/>
					<div class="alert alert-info">{l s='Caution: The discount applied to a category does not stack with the overall reduction but instead replaces it.'}</div>
					{$categoryTreeView}
					<div class="alert alert-warning">{l s='Only products that have this category as the default category will be affected.'}</div>
					<div class="form-group">
						<label class="control-label col-lg-3" for="category_reduction_fancybox">{l s='Discount (%):'}</label>
						<div class="col-lg-9">
							<input type="text" name="category_reduction_fancybox" id="category_reduction_fancybox" value="0.00" class="form-control" />
						</div>
					</div>
					<div class="form-group">
						<div class="col-lg-12">
							<button type="button" onclick="addCategoryReduction();" class="btn btn-default pull-right">{l s='add'}</button>
						</div>
					</div>
				</div>
			</fieldset>
		</div>
	</div>
	{elseif $input['type'] == 'modules'}
	<div style="{if !$form_id}display:none{/if}">
		<div class="margin-form">
		<script type="text/javascript">
			$(document).ready(function() {
				$('#authorized-modules').find('[value="0"]').click(function() {
					$(this).parent().parent().find('input[type=hidden]').attr('name', 'modulesBoxUnauth[]');
				});

				$('#authorized-modules').find('[value="1"]').click(function() {
					$(this).parent().parent().find('input[type=hidden]').attr('name', 'modulesBoxAuth[]');
				});
			});
		</script>

		<div class="col-lg-9" id="authorized-modules">			
			{foreach $input['values']['auth_modules'] key=key item=module }
			<div class="form-group">
				<label class="control-label col-lg-2"><img src="../modules/{$module->name}/logo.gif"> {$module->displayName}</label>
				<div class="input-group col-lg-2">
					<span class="switch prestashop-switch">
						<input type="radio" name="{$module->name}" id="{$module->name}_on" value="1" checked="checked">
						<label class="radio" for="{$module->name}_on"><i class="icon-check-sign color_success"></i> Yes</label>
						<input type="radio" name="{$module->name}" id="{$module->name}_off" value="0">
						<label class="radio" for="{$module->name}_off"><i class="icon-ban-circle color_danger"></i> No</label>
						<span class="slide-button btn btn-default"></span>
					</span>
					<input type="hidden" name="modulesBoxAuth[]" value="{$module->id}">
				</div>
			</div>
			{/foreach}
			{foreach $input['values']['unauth_modules'] key=key item=module }
			<div class="form-group">
				<label class="control-label col-lg-2"><img src="../modules/{$module->name}/logo.gif"> {$module->displayName}</label>
				<div class="input-group col-lg-2">
					<span class="switch prestashop-switch">
						<input type="radio" name="{$module->name}" id="{$module->name}_on" value="1">
						<label class="radio" for="{$module->name}_on"><i class="icon-check-sign color_success"></i> Yes</label>
						<input type="radio" name="{$module->name}" id="{$module->name}_off" value="0" checked="checked">
						<label class="radio" for="{$module->name}_off"><i class="icon-ban-circle color_danger"></i> No</label>
						<span class="slide-button btn btn-default"></span>
					</span>
					<input type="hidden" name="modulesBoxUnauth[]" value="{$module->id}">
				</div>
			</div>
			{/foreach}
		</div>
	</div>
	{else}
		{$smarty.block.parent}
	{/if}
{/block}
