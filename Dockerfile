FROM node:12 AS build

COPY . ./

# potential performance optimization from https://github.com/npm/npm/issues/8836
RUN npm config set registry https://registry.npmjs.org/

# RUN npm i
# RUN npm run build

## Second stage image to be implemented 
# FROM node:12

# WORKDIR /usr/src/app
# COPY package.json ./

# ## Move the UI server into ./dist, and create a public/ folder to serve from
# COPY --from=build dist ./dist
# # Need to do this so the Firebase config can be generated at runtime (don't have to keep static credentials)
# COPY --from=build scripts ./scripts
# COPY --from=build node_modules ./node_modules
# # Need to manually pull over schema for runtime
# COPY --from=build src/graphql/schema.graphql ./dist/graphql

EXPOSE 4000

CMD npm run start