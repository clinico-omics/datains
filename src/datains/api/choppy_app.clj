(ns datains.api.choppy-app
  (:require
   [ring.util.http-response :refer [ok created no-content]]
   [datains.db.handler :as db-handler]
   [datains.api.app-spec :as app-spec]
   [clojure.tools.logging :as log]
   [datains.api.response :as response]
   [datains.events :as events]
   [datains.adapters.file-manager.fs :as fs-libs]
   [digest :as digest]
   [clojure.data.json :as json]
   [datains.adapters.app-store.core :as app-store]))

(def app
  [""
   {:swagger {:tags ["App Store"]}}

   ["/apps"
    {:get  {:summary    "Get apps."
            :parameters {:query app-spec/app-params-query}
            :responses  {200 {:body {:total    nat-int?
                                     :page     pos-int?
                                     :per_page pos-int?
                                     :data     any?}}}
            :handler    (fn [{{{:keys [page per_page title valid author]} :query} :parameters}]
                          (let [query-map {:title  title
                                           :valid  valid
                                           :author author}]
                            (log/debug "page: " page, "per-page: " per_page, "query-map: " query-map)
                            (ok (db-handler/search-apps {:query-map query-map}
                                                        page
                                                        per_page))))}

     :post {:summary    "Create an app."
            :parameters {:body app-spec/app-body}
            :responses  {201 {:body {:message {:id string?}}}}
            :handler    (fn [{{{:keys [id title description repo_url cover icon author rate valid]} :body} :parameters}]
                          (created (str "/apps/" id)
                                   {:message (db-handler/create-app! {:id          id
                                                                      :title       title
                                                                      :description description
                                                                      :repo_url    repo_url
                                                                      :cover       cover
                                                                      :icon        icon
                                                                      :author      author
                                                                      :rate        rate
                                                                      :valid       valid})}))}}]
   ["/installed-apps"
    {:get {:summary    "Get installed apps."
           :parameters {}
           :responses  {200 {:body {:total nat-int?
                                    :data  any?}}}
           :handler    (fn [_]
                         (let [apps (app-store/get-installed-apps (app-store/get-app-workdir))]
                           (ok {:data  (map #(assoc {} :name % :id (digest/md5 %)) apps)
                                :total (count apps)})))}}]
   ["/app-manifest"
    {:get {:summary    "Get the manifest of all installed apps."
           :parameters {}
           :responses  {200 {:body {:total nat-int?
                                    :data  any?}}}
           :handler    (fn [_]
                         (let [manifest (fs-libs/join-paths (app-store/get-app-workdir) "manifest.json")
                               manifest-str (slurp manifest)
                               apps (json/read-json manifest-str true)]
                           (ok {:data  apps
                                :total (count apps)})))}}]])