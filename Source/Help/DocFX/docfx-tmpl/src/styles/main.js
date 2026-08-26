// Use container fluid
var containers = $(".container");
containers.removeClass("container");
containers.addClass("container-fluid");

// Navbar Hamburger
$(function() {
    $(".navbar-toggle").click(function() {
        $(this).toggleClass("change");
    })
})

// Select list to replace affix on small screens
$(function () {
    var navItems = $(".sideaffix .level1 > li");

    if (navItems.length == 0) {
        return;
    }

    var selector = $("<select/>");
    selector.addClass("form-control visible-sm visible-xs");
    var form = $("<form/>");
    form.append(selector);
    form.prependTo("article");

    selector.change(function() {
        window.location = $(this).find("option:selected").val();
    })

    function work(item, level) {
        var link = item.children('a');

        var text = link.text();
        
        for (var i = 0; i < level; ++i) {
            text = '&nbsp;&nbsp;' + text;
        }

        selector.append($('<option/>', {
            'value': link.attr('href'),
            'html': text
        }));

        var nested = item.children('ul');

        if (nested.length > 0) {
            nested.children('li').each(function () {
                work($(this), level + 1);
            });
        }
    }

    navItems.each(function () {
        work($(this), 0);
    });
})

document.addEventListener("DOMContentLoaded", () => {
  // Version switcher: loads /versions.json (NuGet package versions by channel)
  (function insertVersionSwitcher() {
    const match = location.pathname.match(/^(.*\/)?v\/([^/]+)(\/|$)/i);
    if (!match) {
      return;
    }
    const prefix = match[1] || "/";
    const current = decodeURIComponent(match[2]);
    const pageSuffix = location.pathname.slice(match[0].length);
    const nav = document.querySelector(".navbar-nav") || document.querySelector("header nav ul");
    if (!nav) {
      return;
    }

    function siteRootFromPrefix(p) {
      // prefix is everything before "v/<version>/", e.g. "/Standard-Toolkit-Online-Help/"
      return p;
    }

    const root = siteRootFromPrefix(prefix);
    const catalogUrl = root + "versions.json";

    fetch(catalogUrl)
      .then((r) => {
        if (!r.ok) throw new Error("versions.json " + r.status);
        return r.json();
      })
      .then((catalog) => {
        const channelOrder = [
          { key: "stable", label: "Stable" },
          { key: "lts", label: "LTS" },
          { key: "canary", label: "Canary" },
          { key: "nightly", label: "Nightly" }
        ];
        const li = document.createElement("li");
        li.className = "krypton-version-switcher";
        const select = document.createElement("select");
        select.setAttribute("aria-label", "Documentation version");
        select.title = "NuGet package version for API docs";

        channelOrder.forEach((ch) => {
          const entries = (catalog.channels && catalog.channels[ch.key]) || [];
          if (!entries.length) return;
          const group = document.createElement("optgroup");
          group.label = ch.label;
          entries.forEach((entry) => {
            const opt = document.createElement("option");
            const versionPath = (entry.path || ("v/" + entry.version + "/")).replace(/^\//, "");
            opt.value = root + versionPath;
            opt.textContent = entry.version;
            opt.dataset.version = entry.version;
            if (entry.version === current) {
              opt.selected = true;
            }
            group.appendChild(opt);
          });
          select.appendChild(group);
        });

        if (!select.options.length) {
          return;
        }

        select.addEventListener("change", () => {
          const base = select.value.endsWith("/") ? select.value : select.value + "/";
          if (!pageSuffix) {
            location.href = base;
            return;
          }
          const candidate = base + pageSuffix;
          fetch(candidate, { method: "GET", cache: "no-store" })
            .then((r) => {
              location.href = r.ok ? candidate : base;
            })
            .catch(() => {
              location.href = base;
            });
        });

        li.appendChild(select);
        nav.appendChild(li);
      })
      .catch(() => {
        /* catalog missing on local single-tree builds */
      });
  })();

  document.querySelectorAll("pre > code").forEach((codeBlock) => {
    const button = document.createElement("button");
    button.className = "copy-code-button";
    button.innerHTML = '<i class="fa fa-clipboard"></i> Copy';
    button.setAttribute("title", "Copy code to clipboard");

    codeBlock.parentNode.insertBefore(button, codeBlock);

    button.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(codeBlock.textContent);
        button.innerHTML = '<i class="fa fa-check"></i> Copied!';
        button.classList.add("copied");
        setTimeout(() => {
          button.innerHTML = '<i class="fa fa-clipboard"></i> Copy';
          button.classList.remove("copied");
        }, 1500);
      } catch (err) {
        // Fallback for older browsers
        const textArea = document.createElement("textarea");
        textArea.value = codeBlock.textContent;
        document.body.appendChild(textArea);
        textArea.select();
        try {
          document.execCommand('copy');
          button.innerHTML = '<i class="fa fa-check"></i> Copied!';
          button.classList.add("copied");
          setTimeout(() => {
            button.innerHTML = '<i class="fa fa-clipboard"></i> Copy';
            button.classList.remove("copied");
          }, 1500);
        } catch (fallbackErr) {
          button.innerHTML = '<i class="fa fa-times"></i> Failed';
          setTimeout(() => (button.innerHTML = '<i class="fa fa-clipboard"></i> Copy'), 1500);
        }
        document.body.removeChild(textArea);
      }
    });
  });

  // Dynamically update copyright year in footer
  const currentYear = new Date().getFullYear();
  const footer = document.querySelector('.footer');
  if (footer) {
    footer.innerHTML = footer.innerHTML.replace(/2017 - \d{4}/g, `2017 - ${currentYear}`);
  }
});
