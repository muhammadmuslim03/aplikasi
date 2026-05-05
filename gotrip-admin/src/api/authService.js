import api, { getApiErrorMessage } from "./api";

export const login = async (email, password) => {
  try {
    const response = await api.post("/auth/login", {
      email,
      password,
      client: "admin",
    });

    return response.data;
  } catch (error) {
    throw new Error(getApiErrorMessage(error, "Login gagal"));
  }
};
