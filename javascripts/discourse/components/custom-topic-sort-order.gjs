import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { eq } from "truth-helpers";
import DMenu from "float-kit/components/d-menu";
import DropdownMenu from "discourse/components/dropdown-menu";
import DButton from "discourse/components/d-button";
import icon from "discourse-common/helpers/d-icon";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class CustomTopicSortOrder extends Component {
  @service router;

  @tracked currentOrder = null;
  @tracked ascending = null;

  get shouldShow() {
    return this.router.currentRouteName !== "discovery.categories";
  }

  @action
  updateSortFromUrl() {
    const queryParams = new URLSearchParams(window.location.search);
    if (queryParams.has("order") && queryParams.has("ascending")) {
      this.currentOrder = queryParams.get("order");
      this.ascending = queryParams.get("ascending") === "true";
    } else {
      this.currentOrder = null;
      this.ascending = null;
    }
  }

  @action
  toggleSort(orderType) {
    if (this.currentOrder === orderType) {
      this.ascending = !this.ascending;
    } else {
      this.currentOrder = orderType;
      this.ascending = true;
    }
  
    const queryParams = new URLSearchParams(window.location.search);
    queryParams.set("ascending", this.ascending ? "true" : "false");
    queryParams.set("order", orderType);
    DiscourseURL.routeTo(window.location.pathname + "?" + queryParams.toString());
  }

  @action
  onRegisterApi(api) {
    this.dMenu = api;
  }

  <template>
    {{#if this.shouldShow}}
      <DMenu
        @arrow={{true}}
        @identifier="custom-topic-sortable"
        @icon={{settings.custom_topic_sort_order_button_icon}}
        
        {{!-- 
            [关键修改] 标签逻辑：
            1. 检查 settings.show_button_label 是否开启
            2. 若开启，检查是否有 settings.custom_topic_sort_order_button_text
               - 有则显示自定义文本
               - 无则显示默认 i18n 翻译
            3. 若关闭，返回 null (DMenu 将只显示图标)
        --}}
        @label={{if settings.show_button_label (if settings.custom_topic_sort_order_button_text settings.custom_topic_sort_order_button_text (i18n "js.search.sort_by"))}}
        
        @closeOnScroll={{true}}
        id="topic-sortable"
        class="icon btn-default"
        @modalForMobile={{false}}
        @onRegisterApi={{this.onRegisterApi}}
      >
       
        <:content>
          <DropdownMenu as |dropdown|>
            {{#each settings.custom_topic_sort_order_items as |item|}}
              <dropdown.item>
                <DButton
                  @icon={{item.icon}}
                  @translatedLabel={{i18n item.label}}
                  @action={{fn this.toggleSort item.action}}
                  class="btn btn-transparent sortable-dd-item"
                >
                  {{icon (if (eq this.currentOrder item.action) (if this.ascending settings.descending_icon settings.ascending_icon) null)}}
                </DButton>
              </dropdown.item>
            {{/each}}
          </DropdownMenu>
        </:content>
      </DMenu>
    {{/if}}
  </template>
}
