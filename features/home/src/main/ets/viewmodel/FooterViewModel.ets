export class FooterTabViewModel {
  private tabList: FooterTab[] = [];

  constructor() {
    this.tabList.push(new FooterTab($r('app.string.tab_home'), $r('app.media.ic_tabs_home_normal'),
      $r('app.media.ic_tabs_home_selected')));
    this.tabList.push(new FooterTab($r('app.string.tab_collections'), $r('app.media.ic_tabs_collection_normal'),
      $r('app.media.ic_tabs_collection_selected')));
  }

  getTabList(): FooterTab[] {
    return this.tabList;
  }
}

export class FooterTab {
  /**
   * Name of the tab.
   */
  private _name: Resource;
  /**
   * Icon of the tab.
   */
  private _icon: Resource;
  /**
   * Icon selected.
   */
  private _iconSelected: Resource;

  constructor(name: Resource, icon: Resource, iconSelected: Resource) {
    this._name = name;
    this._icon = icon;
    this._iconSelected = iconSelected;
  }

  getName(): Resource {
    return this._name;
  }

  getIcon(): Resource {
    return this._icon;
  }

  getIconSelected(): Resource {
    return this._iconSelected;
  }
}