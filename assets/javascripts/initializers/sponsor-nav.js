import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";

export default {
  name: "sponsor-nav",
  initialize() {
    withPluginApi("0.8.7", (api) => {
      api.addNavigationBarItem({
        name: "sponsor",
        displayName: I18n.t("discourse_plugin_name.sponsor_nav_label"),
        href: "/sponsor",
        onClick: (event) => {
          const currentUser = api.getCurrentUser();

          if (!currentUser) {
            event?.preventDefault();

            const dialog = api.container.lookup("service:dialog");
            const message = I18n.t("discourse_plugin_name.login_required");

            if (dialog?.alert) {
              dialog.alert(message);
            } else if (window.bootbox?.alert) {
              window.bootbox.alert(message);
            }

            return false;
          }

          return true;
        },
      });
    });
  },
};
