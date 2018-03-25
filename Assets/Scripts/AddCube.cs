using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AddCube : MonoBehaviour {

	public GameObject prefab;
	public int CubeNum;

	float rotateY = 0;
	float RADIAN = Mathf.PI / 180;

	void Start () {
		for (int i = 0; i < CubeNum; i++) {
			float radius = Random.Range(0.0f, 100);
			float rad = Random.Range(0, 360) * RADIAN;
			float rad2 = Random.Range(0, 360) * RADIAN;

			Vector3 pos = new Vector3(
				Mathf.Cos(rad) * Mathf.Cos(rad2) * (radius),
				Mathf.Cos(rad) * Mathf.Sin(rad2) * (radius),
				Mathf.Sin(rad) * (radius)
			);

			GameObject instance = Instantiate (prefab, pos, Quaternion.identity);
			instance.transform.parent = gameObject.transform;
		}
	}
	
	void Update () {
		gameObject.transform.rotation = Quaternion.Euler(0, rotateY, 0);
		rotateY ++;
	}
}
